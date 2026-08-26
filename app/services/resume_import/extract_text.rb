module ResumeImport
  class ExtractText
    def initialize(io)
      @io = io
    end

    def call
      PDF::Reader.new(io).pages.map(&:text).join("\n\n")
    end

    private

    attr_reader :io
  end
end
