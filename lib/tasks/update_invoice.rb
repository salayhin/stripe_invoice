class UpdateInvoice

  def self.update
    @owners = ::Koudoku.owner_class

    @owners.find_each do |owner|

      begin
        @subscription = owner.subscription

        if @subscription
          @stripe_invoices = Stripe::Invoice.all(
              :customer => @subscription.stripe_id,
              :limit => 100)

          @stripe_invoices.each do |sinvoice|
            next if StripeInvoice::Invoice.find_by_stripe_id(sinvoice.id)
            StripeInvoice::Invoice.create({
                                              stripe_id: sinvoice.id,
                                              owner_id: owner.id,
                                              date: sinvoice.date,
                                              invoice_number: "ls-#{Date.today.year}-#{(StripeInvoice::Invoice.last ? (StripeInvoice::Invoice.last.id * 7) : 1).to_s.rjust(5, '0')}",
                                              json: sinvoice
                                          })
          end
        end

        notification_logger.error "Success: Created invoice. Time: #{Time.now}"

      rescue => e
        notification_logger.error "Error: Creating invoice. Time: #{Time.now}"
        notification_logger.error e.message
        notification_logger.debug e.backtrace.join('\n')
      end

    end
  end

  def self.notification_logger
    @notification_logger ||= Logger.new('log/stripe_invoice.log')
    @notification_logger
  end
end