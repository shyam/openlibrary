require 'mail'
require 'erb'

class Email
  attr_accessor :to, :book

  def initialize to, book
    @to = to
    @book = book
  end

  def send_reserved_msg
    return unless @to.employee_id == 13079
    send_email 'You have taken a book from library', 'reserve'
  end

  private

  def get_erb_content filename
    erb_file = File.join(File.dirname(__FILE__), '../views/mail/', "#{filename}.erb")
    File.new(erb_file).read
  end

  def send_email mail_subject, template
    renderer = ERB.new get_erb_content(template)
    to_address = "#{@to.employee_id}@thoughtworks.com"
    mail_body = renderer.result(binding)

    mail = Mail.new do
      from  "admin@openlibrary.thoughtworks.com"
      to to_address 
      subject mail_subject 
      html_part do
        content_type 'text/html; charset=UTF-8'
        body mail_body
      end
    end
    p mail.to_s
  end

end
