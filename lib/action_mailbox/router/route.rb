class ActionMailbox::Router::Route
  attr_reader :address, :mailbox_name

  def initialize(address, to:)
    @address, @mailbox_name = address, to

    ensure_valid_address
  end

  def match?(inbound_email)
    case address
    when String
      recipients_from(inbound_email.mail).any? { |recipient| address.casecmp?(recipient) }
    when Regexp
      recipients_from(inbound_email.mail).any? { |recipient| address.match?(recipient) }
    when Proc
      address.call(inbound_email)
    else
      address.match?(inbound_email)
    end
  end

  def mailbox_class
    "#{mailbox_name.to_s.camelize}Mailbox".constantize
  end

  private
    def ensure_valid_address
      unless [ String, Regexp, Proc ].any? { |klass| address.is_a?(klass) } || address.respond_to?(:match?)
        raise ArgumentError, "Expected a String, Regexp, Proc, or matchable, got #{address.inspect}"
      end
    end

    def recipients_from(mail)
      Array(mail.to) + Array(mail.cc) + Array(mail.bcc)
    end
end
