$LOAD_PATH.unshift File.dirname(__FILE__)
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../calculate'
$LOAD_PATH.unshift File.dirname(__FILE__) + '/../config'

def require_folder *folders
  folders.each do |folder|
    if Dir.exists? folder
      $LOAD_PATH << File.dirname(__FILE__) + '/' + folder
      Dir.new(folder).grep(/\.rb/) {|rb_file| require rb_file}    
    end
  end
end

require_folder File.dirname(__FILE__) + '/../calculate'


# loop our task here

EDWFactCaculate::Yottaplatform.new.get_data

# sleep one day


