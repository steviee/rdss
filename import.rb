
# Stevie's file impoter'n'stuff
#
# the plan: read file from INBOUND and 
#   - copy it to WORK
#   - store local file name, change file name to unique key (DOCID)
#   - generate PDF of file DOCID.pdf
#   - generate JPG of each page (DOCID_p.jpg)
#   - generate thumbnail image (JPG) of each JPG (DOCID_t.jpg)
#   - generate JSON file of original file meta data (DOCID.json)
#   - store everything in MongoDb GRIDFS
#   - be happy!

require 'RMagick'
require 'libreconv'

include Magick
BASEDIR = File.dirname(__FILE__)


def create_pdf(file)
	puts "Creating PDF of #{file}"

	pdf_file = "#{BASEDIR}/work/#{File.basename(file, File.extname(file))}.pdf"

	Libreconv.convert file, pdf_file
	return pdf_file
end

def create_images(file)


	pdf = Magick::Image.read(file)	
	pg = 1
	pdf.each do |page|
		jpg_file = "#{BASEDIR}/work/#{File.basename(file, File.extname(file))}_#{pg}.jpg"
		pg += 1
		puts "Creating JPG #{jpg_file}"
		page.write(jpg_file){ self.units= Magick::ResolutionType::PixelsPerInchResolution; self.density="200"; self.quality=90 }
	end


end	

def import

	# gimme the files
	files = Dir.glob("#{BASEDIR}/inbound/**/*")

	files.each do |file|

		puts "Converting #{file}"

		work_name = "#{BASEDIR}/work/#{File.basename(file)}" 
		done_name = "#{BASEDIR}/imported/#{File.basename(file)}" 
		error_name = "#{BASEDIR}/error/#{File.basename(file)}" 

		puts "Moving to #{work_name}"
		File.rename file, work_name # ok, file is now in work_dir

		pdf = create_pdf(work_name)

		create_images(pdf)


	end
end

import


