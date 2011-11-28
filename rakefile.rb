require 'albacore'

MSBUILD = "C:/Windows/Microsoft.NET/Framework/v4.0.30319/MSBuild.exe"
NUGET = File.join(Dir.pwd, 'tools', 'nuget.exe')

OUTPUT_DIR = 'Output'
WEB_OUTPUT = File.join(Dir.pwd, OUTPUT_DIR, 'Site')

NUPSEC_FILE = 'mvcweb.nuspec'
NUSPEC_FILES_PATTERN = 'site\**\*.*'

@version = ENV["VERSION"] || '1.0.0.0'
@config = ENV["CONFIG"] || 'Debug'

desc "deploy web"
task :deploy do		
	task('clean').execute()
	task('build').execute()
	task('nuget:spec').execute()
	task('nuget:pack').execute()
end

desc "build web"
task :build do		
	puts "Building site in: #{WEB_OUTPUT}"
	task('compile:site').execute(:project_file => "web/web.csproj", :target_dir => WEB_OUTPUT) 
end

task :clean do 
	FileUtils.remove_dir OUTPUT_DIR, true
	FileUtils.mkdir OUTPUT_DIR
end	
	
namespace :compile do 
	
	desc "Compile a web site project"
	msbuild :site, :project_file, :target_dir do |msb, args|
		msb.command = MSBUILD
		msb.properties  = {
			"Configuration" => "#{@config}", 
			"WebProjectOutputDir" => "#{args[:target_dir]}",
			"OutputPath" => "#{args[:target_dir]}/bin/"
		}
		msb.targets :Rebuild, :ResolveReferences, :_WPPCopyWebApplication
		msb.verbosity = "normal"
		msb.log_level = :verbose
		msb.solution = args[:project_file]
	end
	
end	
	
namespace :nuget do 	
	
	desc "create the nuget package"
	nuspec :spec do |nuspec|
	   nuspec.id="mvcweb"
	   nuspec.version = @version
	   nuspec.authors = "me"
	   nuspec.description = "mvc web is a webapplication"
	   nuspec.title = "mvc web"
	   nuspec.language = "en-US"
	   nuspec.licenseUrl = "http://me.com/license"
	   nuspec.projectUrl = "http://me.com"
	   nuspec.working_directory = OUTPUT_DIR
	   nuspec.output_file = NUPSEC_FILE
	   nuspec.file NUSPEC_FILES_PATTERN, "."
	end

	desc "create the nuget package"
	nugetpack :pack do |nuget|
	   nuget.command     = NUGET
	   nuget.nuspec      = File.join(OUTPUT_DIR, NUPSEC_FILE)
	   # nuget.base_folder = OUTPUT_DIR + '/'
	   nuget.output      = OUTPUT_DIR
	end
	
end