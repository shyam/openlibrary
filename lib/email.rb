require 'mail'
require 'erb'

class Email
  attr_accessor :to, :book

  def initialize to, book
    @to = to
    @book = book
  end

  def send_issued_msg
    send_email 'You have taken a book from library', 'issued'
  end

  def send_returned_msg
    send_email 'You have placed the book back in the library', 'returned'
  end

  def send_barcode_image
    send_email 'OpenLibrary Barcode', '', true
  end

  private

  def get_erb_content filename
    erb_file = File.join(File.dirname(__FILE__), '../views/mail/', "#{filename}.erb")
    File.new(erb_file).read
  end

  def send_email mail_subject, template, attachment = false
    renderer = ERB.new get_erb_content(template)
    to_address = "#{@to.employee_id}@thoughtworks.com"
    mail_body = renderer.result(binding)

    mail = Mail.new do
      from "admin@openlibrary.thoughtworks.com"
      to to_address
      subject mail_subject
      add_file "barcode_images/#{@to.employee_id}.png" if attachment
      html_part do
        content_type 'text/html; charset=UTF-8'
        body mail_body
      end
      delivery_method :sendmail
    end
    mail.deliver
  end

end
