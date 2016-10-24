require 'test_helper'

class ContextTest < IchniteTest
  def test_enter
    Ichnite.enter job_id: '123456', job_class: 'SampleJob'
    Ichnite.log(:invoice_sent, customer_id: 234, total: 48.35)

    assert_log "event=invoice_sent job_id=123456 job_class=SampleJob customer_id=234 total=48.35"
  end

  def test_enter_many
    Ichnite.enter job_id: '123456'
    Ichnite.enter job_class: 'SampleJob'
    Ichnite.log(:invoice_sent, customer_id: 234, total: 48.35)

    assert_log "event=invoice_sent job_id=123456 job_class=SampleJob customer_id=234 total=48.35"
  end

  def test_enter_block
    Ichnite.log(:one)
    Ichnite.enter job_id: '123456' do
      Ichnite.log(:two)
      Ichnite.enter job_class: '123456' do
        Ichnite.log(:three)
      end
      Ichnite.log(:four)
    end
    Ichnite.log(:five)

    assert_logs(
      "event=one",
      "event=two job_id=123456",
      "event=three job_id=123456 job_class=123456",
      "event=four job_id=123456",
      "event=five"
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

    assert_logs(
      "event=one",
      "event=not_implemented",
      "event=two"
    )
  end

  def test_leave
    Ichnite.enter job_id: '123456', job_class: 'SampleJob'

    Ichnite.leave :job_id
    Ichnite.log(:invoice_sent, customer_id: 234, total: 48.35)

    assert_log "event=invoice_sent job_class=SampleJob customer_id=234 total=48.35"
  end

  def test_leave_many
    Ichnite.enter job_id: '123456', job_class: 'SampleJob'

    Ichnite.leave :job_id, :job_class
    Ichnite.log(:invoice_sent, customer_id: 234, total: 48.35)

    assert_log "event=invoice_sent customer_id=234 total=48.35"
  end

  def test_leave_all
    Ichnite.enter job_id: '123456', job_class: 'SampleJob'

    Ichnite.leave
    Ichnite.log(:invoice_sent, customer_id: 234, total: 48.35)

    assert_log "event=invoice_sent customer_id=234 total=48.35"
  end

  def test_augment
    Ichnite.augment do
      { level: :info }
    end
    Ichnite.log(:message_received)

    assert_log "event=message_received level=info"
  end
end
