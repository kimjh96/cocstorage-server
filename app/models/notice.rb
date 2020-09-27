class Notice < ApplicationRecord
  belongs_to :user

  has_many_attached :images

  def self.fetch_with_options(options = {})
    notices = all

    if options[:orderBy].present?
      notices = notices.order(created_at: :desc) if options[:orderBy] == 'latest'
      notices = notices.order(created_at: :asc) if options[:orderBy] == 'old'
    end

    notices
  end

  def self.find_with_options(options = {})
    options = options.merge(is_active: true)

    notice = find_by(options)
    raise Errors::BadRequest.new(code: 'COC006', message: "There's no such resource.") if notice.blank?

    notice
  end

  def self.update_with_options(options = {})
    notice = find_by(options.except(:subject, :content))
    raise Errors::BadRequest.new(code: 'COC006', message: "There's no such resource.") if notice.blank?

    content_html = Nokogiri::HTML.parse(options[:content])
    options = options.merge(description: content_html.text)

    options = options.except(:user)
    options = options.merge(is_draft: false)

    notice.update(options).inspect
    notice
  end

  def thumbnail_url
    first_files_url_of(images)
  end

  def last_image_url
    last_files_url_of(images)
  end
end