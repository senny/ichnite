require 'test_helper'

class ContextTest < IchniteTest
  def test_enter
    Ichnite.enter job_id: '123456', job_class: 'SampleJob'
    Ichnite.log(:invoice_sent, customer_id: 234, total: 48.35)

    assert_ichnite_events(
      ['invoice_sent', { job_id: '123456', job_class: 'SampleJob', customer_id: 234, total: 48.35 }],
    )
  end

  def test_enter_many
    Ichnite.enter job_id: '123456'
    Ichnite.enter job_class: 'SampleJob'
    Ichnite.log(:invoice_sent, customer_id: 234, total: 48.35)

    assert_ichnite_events(
      ['invoice_sent', { job_id: '123456', job_class: 'SampleJob', customer_id: 234, total: 48.35 }],
    )
  end

  def test_enter_block
    Ichnite.log(:one)
    Ichnite.enter job_id: '123456' do
      Ichnite.log(:two)
      Ichnite.enter job_class: 'AJob' do
        Ichnite.log(:three)
      end
      Ichnite.log(:four)
    end
    Ichnite.log(:five)

    assert_ichnite_events(
      ['one', {}],
      ['two', { job_id: '123456' }],
      ['three', { job_id: '123456', job_class: 'AJob' }],
      ['four', { job_id: '123456' }],
      ['five', {}]
    )
  end

  def test_enter_block_leaves_with_exception
    Ichnite.log(:one)
    begin
      Ichnite.enter job_id: '123456' do
        raise NotImplementedError
      end
    rescue NotImplementedError
      Ichnite.log(:not_implemented)
    end
    Ichnite.log(:two)

    assert_ichnite_events(
      ['one', {}],
      ['not_implemented', {}],
      ['two', {}]
    )
  end

  def test_leave
    Ichnite.enter job_id: '123456', job_class: 'SampleJob'

    Ichnite.leave :job_id
    Ichnite.log(:invoice_sent, customer_id: 234, total: 48.35)

    assert_ichnite_events ['invoice_sent', job_class: 'SampleJob', customer_id: 234, total: 48.35]
  end

  def test_leave_many
    Ichnite.enter job_id: '123456', job_class: 'SampleJob'

    Ichnite.leave :job_id, :job_class
    Ichnite.log(:invoice_sent, customer_id: 234, total: 48.35)

    assert_ichnite_events ['invoice_sent', customer_id: 234, total: 48.35]
  end

  def test_leave_all
    Ichnite.enter job_id: '123456', job_class: 'SampleJob'

    Ichnite.leave
    Ichnite.log(:invoice_sent, customer_id: 234, total: 48.35)

    assert_ichnite_events ['invoice_sent', customer_id: 234, total: 48.35]
  end

  def test_augment
    Ichnite.augment do
      { level: :info }
    end
    Ichnite.log(:message_received)

    assert_ichnite_events ['message_received', level: :info]
  end
end
