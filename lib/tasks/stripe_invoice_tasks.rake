require 'tasks/update_invoice'

namespace :stripe_invoice_tasks do

  #=========<$ Task for create Invoice  $>=========#
  desc 'update invoice every night'
  task update_invoice: :environment do
    UpdateInvoice.update
  end
end
