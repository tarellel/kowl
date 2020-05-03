# frozen_string_literal: true

# https://github.com/gitcoinco/code_fund_ads/blob/b87cc931f167dadc96904cec8d653d76bc55b021/app/jobs/download_and_extract_maxmind_file_job.rb
# https://cobwwweb.com/download-collection-of-images-from-url-using-ruby
require 'net/http'
require 'fileutils'
require 'zlib'
require 'rubygems/package'

# Used for fetching the GeoLite db from maxmind
class GeoDB
  GEOLITE_URL = 'http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.tar.gz'

  # Begin creating folders and being downloadding the GeoLite db
  # @param path [String] the applications relative path
  # @return [Boolean] if the GeoLite2 database was successfully downloaded and decompressed
  def self.perform(path)
    const_set('GEOLIB_DIR', File.join(path, 'db/maxmind'))
    const_set('GEOLIB_PATH', File.join(GEOLIB_DIR, 'GeoLite2-City.tar.gz'))

    FileUtils.mkdir_p GEOLIB_DIR
    download
    extract
  rescue => e
    puts "Error while setting up GeoLite DB - #{e.message}"
  end

  # Download the file from the GEOLITE url
  # @return [Boolean] returns if the the file was succcessfully downloaded
  def self.download
    FileUtils.rm_f GEOLIB_PATH
    res = Net::HTTP.get_response(URI.parse(GEOLITE_URL))
    File.open(GEOLIB_PATH, 'wb') do |f|
      f.write(res.body)
    end
  rescue => e
    puts 'GeoLite2 database could not be downloaded at this time.'
    puts e.message if e.message
  end

  private

  # Extract the GEOLIB tar.gz file into the application
  # @return [Boolean] if the file was sucessfully decompressed
  def self.extract
    untar(unzip(GEOLIB_PATH))
  end

  # Uncompress the zipfile
  #  https://www.rubydoc.info/gems/folio/0.4.0/ZipUtils.ungzip
  # @param file [String] the specific file path/name
  # @param options [Hash] any specific options required for decompressing the file [:dryrun] || [:noop]
  # @return [Boolean] if the File was sucessfully decompressed
  def self.unzip(file, options = {})
    # Decompress the file to the specified location
    fname = File.join(GEOLIB_DIR, File.basename(file).chomp(File.extname(file)))
    # Remove unzipped file if it already exists for any reason
    FileUtils.rm_f fname
    Zlib::GzipReader.open(file) do |gz|
      File.open(fname, 'wb'){ |f| f << gz.read }
    end unless options[:dryrun] || options[:noop]
    FileUtils.rm_f GEOLIB_PATH
    File.expand_path(fname)
  rescue => e
    puts "Error occured while extracting the geolite database #{e}"
  end

  # Untar the specified file
  # @param tarred_path [String] the specific filename/path for the tar file
  # @return [Boolean] if the file was successfully decompressed
  def self.untar(tarred_path)
    Gem::Package::TarReader.new File.open(tarred_path) do |tar|
      tar.each do |tarfile|
        next if tarfile.directory?

        destination = db_destinsation(tarfile.full_name)
        FileUtils.mkdir_p File.dirname(destination)
        File.open destination, 'wb' do |f|
          f.print tarfile.read
        end
      end
    end
    FileUtils.rm_rf tarred_path
  rescue => e
    puts "And error occurred while decompressing the database: #{e}"
  end

  # The destination of where the tarfile is loaded
  # @param file [String] the specific geolite database file locattion
  # @return [String] to the GEOLIB database file
  def self.db_destinsation(file)
    file_arr = file.split('/')
    file = (file_arr.count > 1 ? file_arr.last : file_arr)
    File.join(GEOLIB_DIR, file)
  end
end
