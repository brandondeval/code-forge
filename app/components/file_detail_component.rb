class FileDetailComponent < ViewComponent::Base
  MAX_RENDER_BYTES = 1.megabyte

  def initialize(repository:, path:, file_path:)
    @repository = repository
    @path = path
    @file_path = file_path
  end

  def highlighted_content
    return "File is too large to display (over 1 MB)." if @file_path.size > MAX_RENDER_BYTES
    return "Binary file preview is not available." if binary?

    formatter.format(lexer.lex(content)).html_safe
  end

  def language
    lexer.tag.capitalize
  end

  def file_name
    File.basename(@path)
  end

  def parent_path
    parent = File.dirname(@path)
    parent == "." ? nil : parent
  end

  private

  def content
    @content ||= @file_path.read.encode("UTF-8", invalid: :replace, undef: :replace, replace: "�")
  end

  def binary?
    @binary ||= @file_path.binread(8_192).include?("\x00")
  end

  def lexer
    @lexer ||= Rouge::Lexer.guess(filename: @path, source: content) || Rouge::Lexers::PlainText
  end

  def formatter
    @formatter ||= Rouge::Formatters::HTML.new
  end
end
