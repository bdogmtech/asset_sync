module AssetSync
  class Config
    include ActiveModel::Validations

    class Invalid < StandardError; end

    # AssetSync
    attr_accessor :existing_remote_files # What to do with your existing remote files? (keep or delete)
    attr_accessor :gzip_compression
    attr_accessor :manifest
    attr_accessor :fail_silently
    attr_accessor :log_silently
    attr_accessor :always_upload
    attr_accessor :ignored_files
    attr_accessor :prefix
    attr_accessor :public_path
    attr_accessor :enabled
    attr_accessor :custom_headers
    attr_accessor :run_on_precompile
    attr_accessor :invalidate
    attr_accessor :cdn_distribution_id

    # Amazon AWS
    attr_accessor :aws_bucket, :aws_reduced_redundancy, :aws_iam_roles

    validates :existing_remote_files, :inclusion => { :in => %w(keep delete ignore) }

    validates :aws_bucket,          :presence => true

    def initialize
      self.aws_bucket = nil
      self.existing_remote_files = 'keep'
      self.gzip_compression = false
      self.manifest = false
      self.fail_silently = false
      self.log_silently = true
      self.always_upload = []
      self.ignored_files = []
      self.custom_headers = {}
      self.enabled = true
      self.run_on_precompile = true
      self.cdn_distribution_id = nil
      self.invalidate = []
    end

    def manifest_path
      directory =
        Rails.application.config.assets.manifest || default_manifest_directory
      File.join(directory, "manifest.yml")
    end

    def gzip?
      self.gzip_compression
    end

    def existing_remote_files?
      ['keep', 'ignore'].include?(self.existing_remote_files)
    end

    def aws?
      true
    end

    def aws_rrs?
      aws_reduced_redundancy == true
    end

    def aws_iam?
      aws_iam_roles == true
    end

    def fail_silently?
      fail_silently || !enabled?
    end

    def log_silently?
      ENV['RAILS_GROUPS'] == 'assets' || self.log_silently == false
    end

    def enabled?
      enabled == true
    end

    def yml_exists?
      false
    end

    def assets_prefix
      # Fix for Issue #38 when Rails.config.assets.prefix starts with a slash
      self.prefix || Rails.application.config.assets.prefix.sub(/^\//, '')
    end

    def public_path
      @public_path || Rails.public_path
    end

  private

    def default_manifest_directory
      File.join(Rails.public_path, assets_prefix)
    end
  end
end
