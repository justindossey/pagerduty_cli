# encoding: utf-8
require 'spec_helper'

describe PagerdutyCli do
  it 'defines the PagerdutyCli module' do
    expect(PagerdutyCli).to be_a(Module)
  end
  it 'defines the PagerdutyCli::Common module' do
    expect(PagerdutyCli::Common).to be_a(Module)
  end
  it 'croaks properly' do
    # stub for testing the cli
    stub_actor = StubPagerdutyCliActor.new
    out = 'Stub Actor Error: hi Exiting.'
    allow($stderr).to receive(:puts).with(out).and_return(out)
    expect { stub_actor.croak('hi') }.to raise_error(SystemExit)
    expect($stderr).to have_received(:puts).with(out)
  end

  it 'warns properly' do
    stub_actor = StubPagerdutyCliActor.new
    out = 'Stub Actor Warning: hi'
    allow($stderr).to receive(:puts).with(out).and_return(out)
    stub_actor.warn('hi')
    expect($stderr).to have_received(:puts).with(out)
  end

  it 'generates the same key for triggers and resolves' do
    stub_actor = StubPagerdutyCliActor.new
    stub_actor.options[:host] = 'foo'
    stub_actor.options[:event] = 'bar'
    allow(Digest::SHA1).to receive(:hexdigest).with('foo:bar')
    stub_actor.incident_key
    expect(Digest::SHA1).to have_received(:hexdigest).with('foo:bar')
  end

  it 'generates a valid incident filename' do
    stub_actor = StubPagerdutyCliActor.new
    stub_actor.options[:host] = 'foo'
    stub_actor.options[:event] = 'bar'
    stub_actor.options[:tmpdir] = '/FAKETEMP'
    allow(stub_actor).to receive(:incident_key).and_return('x')
    expect(stub_actor.incident_file).to eq('/FAKETEMP/pagerduty-x')
  end

  it 'bails when no API key is loaded' do
    stub_actor = StubPagerdutyCliActor.new
    stub_actor.options[:api_key_file] = 'nonexistent_file'
    allow(stub_actor).to receive(:croak)
    stub_actor.load_data
    expect(stub_actor).to have_received(:croak)
  end

  it 'defines the PagerdutyCli::Trigger class' do
    expect(PagerdutyCli::Trigger).to be_a(Class)
  end

  it 'processes common PagerdutyCli options' do
    args = %w(-H foo -k bar -e baz -t /var/tmp)
    stub_actor = StubPagerdutyCliActor.new
    stub_optionparser = OptionParser.new
    stub_actor.parse_common_options(stub_optionparser)
    stub_optionparser.parse!(args)

    expect(stub_actor.options[:host]).to eq('foo')
    expect(stub_actor.options[:api_key_file]).to eq('bar')
    expect(stub_actor.options[:tmpdir]).to eq('/var/tmp')
    expect(stub_actor.options[:event]).to eq('baz')
  end

  it 'supports correct defaults' do
    args = %w(-e foo)
    stub_actor = StubPagerdutyCliActor.new
    stub_optionparser = OptionParser.new
    stub_actor.parse_common_options(stub_optionparser)
    stub_optionparser.parse!(args)
    expect(stub_actor.options[:host]).to eq(ENV['HOSTNAME'])
    expect(stub_actor.options[:api_key_file])
      .to eq(PagerdutyCli::Common::API_KEY_FILE)
    expect(stub_actor.options[:tmpdir]).to eq('/tmp')
    expect(stub_actor.options[:event]).to eq('foo')
  end

  it 'prints help and exits with -h' do
    args = %w(-h)
    stub_actor = StubPagerdutyCliActor.new
    stub_optionparser = OptionParser.new
    stub_actor.parse_common_options(stub_optionparser)
    allow($stderr).to receive(:puts)
    expect { stub_optionparser.parse!(args) }.to raise_error(SystemExit)
    expect($stderr).to have_received(:puts)
  end

  it 'processes trigger options' do
    args = %w(-f -n -i 600 -e foo)
    allow_any_instance_of(PagerdutyCli::Trigger).to receive(:load_data)
    allow_any_instance_of(PagerdutyCli::Trigger)
      .to receive(:touch_incident_file)
    allow_any_instance_of(PagerdutyCli::Trigger)
      .to receive(:incident_is_too_fresh?).and_return(true)
    PagerdutyCli::Trigger.class_eval('attr_reader :options')
    trigger = PagerdutyCli::Trigger.new(args)

    expect(trigger.options).to be_a(Hash)
    expect(trigger.options[:force]).to be_truthy
    expect(trigger.options[:no_touch]).to be_truthy
    expect(trigger.options[:interval]).to eq(600)
    expect(trigger.options[:event]).to eq('foo')
  end

  it 'places tmp files in the right location' do
    args = %w(-e foo)
    allow_any_instance_of(PagerdutyCli::Trigger)
      .to receive(:incident_is_too_fresh?).and_return(false)
    allow_any_instance_of(PagerdutyCli::Trigger).to receive(:load_data)
    trigger = PagerdutyCli::Trigger.new(args)
    string_buffer = StringIO.new
    allow(File).to receive(:open).and_return(string_buffer)
    allow(trigger).to receive(:incident_key).and_return('abc')
    trigger.send(:touch_incident_file)
    expect(File).to have_received(:open).with('/tmp/pagerduty-abc', 'a')
  end

  it 'allows triggers to be sent via class method' do
    args = %w(-e foo)
    allow_any_instance_of(PagerdutyCli::Trigger).to receive(:load_data)
    allow_any_instance_of(PagerdutyCli::Trigger)
      .to receive(:send_trigger).and_return('bar')

    expect(PagerdutyCli::Trigger.trigger(args)).to eq('bar')
  end

  it 'defines the PagerdutyCli::Resolve class' do
    expect(PagerdutyCli::Resolve).to be_a(Class)
  end

  it 'processes all options to resolve' do
    args = %w(-H foo -k bar -e baz -t /var/tmp)
    allow_any_instance_of(PagerdutyCli::Resolve).to receive(:load_data)
    PagerdutyCli::Resolve.class_eval('attr_reader :options')
    resolver = PagerdutyCli::Resolve.new(args)
    expect(resolver.options[:host]).to eq('foo')
    expect(resolver.options[:api_key_file]).to eq('bar')
    expect(resolver.options[:event]).to eq('baz')
    expect(resolver.options[:tmpdir]).to eq('/var/tmp')
  end

  it 'removes tmp files in the right location' do
    # stub pagerduty API so we can resolve without getting too deep
    class FakePagerDuty
    end
    my_fake_pagerduty = FakePagerDuty.new
    allow(my_fake_pagerduty).to receive(:resolve).and_return(true)

    allow_any_instance_of(Pagerduty)
      .to receive(:get_incident).and_return(my_fake_pagerduty)
    allow_any_instance_of(PagerdutyCli::Resolve)
      .to receive(:incident_file).and_return('foo')
    allow_any_instance_of(PagerdutyCli::Resolve).to receive(:load_data)
    allow(File).to receive(:delete).with('foo').and_return(true)
    PagerdutyCli::Resolve.resolve(%w(-e abc))
    expect(File).to have_received(:delete).with('foo')
    expect(my_fake_pagerduty).to have_received(:resolve)
  end

  it 'allows resolves to be sent via class method' do
    args = %w(-e foo)
    allow_any_instance_of(PagerdutyCli::Resolve).to receive(:load_data)
    allow_any_instance_of(PagerdutyCli::Resolve)
      .to receive(:send_resolve).and_return('bar')
    expect(PagerdutyCli::Resolve.resolve(args)).to eq('bar')
  end

end
