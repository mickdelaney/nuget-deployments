require 'albacore'

MSBUILD = "C:/Windows/Microsoft.NET/Framework/v4.0.30319/MSBuild.exe"
NUGET = File.join(Dir.pwd, 'tools', 'nuget.exe')

OUTPUT_DIR = 'Output'
WEB_OUTPUT = File.join(Dir.pwd, OUTPUT_DIR, 'Site')
SERVICES_OUTPUT = File.join(Dir.pwd, OUTPUT_DIR, 'Services')

@version = ENV["VERSION"] || '1.0.0.0'
@config = ENV["CONFIG"] || 'Debug'

desc "deploy web"
task :deploy do		
	task('clean').execute()
	task('build').execute()
	
	task('nuget:spec').execute(:package_id => "mvcweb", :nuspec_file => 'mvcweb.nuspec', :nuspec_file_pattern => 'Site\**\*.*')
	task('nuget:spec').execute(:package_id => "winsrv", :nuspec_file => 'winsrv.nuspec', :nuspec_file_pattern => 'Services\**\*.*')
	
	task('nuget:pack').execute(:package_id => "mvcweb", :nuspec_file => File.join(OUTPUT_DIR, 'mvcweb.nuspec'))
	task('nuget:pack').execute(:package_id => "winsrv", :nuspec_file => File.join(OUTPUT_DIR, 'winsrv.nuspec'))
end

desc "build web"
task :build do		
	puts "Building site in: #{WEB_OUTPUT}"
	task('compile:site').execute(:project_file => "src/web/web.csproj", :target_dir => WEB_OUTPUT) 
	task('compile:library').execute(:project_file => "src/services/services.csproj", :target_dir => SERVICES_OUTPUT) 
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
	
	desc "Compile a library project"
	msbuild :library, :project_file, :target_dir do |msb, args|
		msb.command = MSBUILD
		msb.properties  = { "Configuration" => "#{@config}", "OutputPath" => "#{args[:target_dir]}" }
		msb.targets :Build
		msb.verbosity = "normal"
		msb.log_level = :verbose
		msb.solution = args[:project_file]
	end
end	
	
namespace :nuget do 	
	
	desc "create the nuget package"
	nuspec :spec, :package_id, :nuspec_file, :nuspec_file_pattern  do |nuspec, args|
	   nuspec.id = args[:package_id]
	   nuspec.version = @version
	   nuspec.authors = "me"
	   nuspec.description = args[:package_id]
	   nuspec.title = args[:package_id]
	   nuspec.language = "en-US"
	   nuspec.licenseUrl = "http://me.com/license"
	   nuspec.projectUrl = "http://me.com"
	   nuspec.working_directory = OUTPUT_DIR
	   nuspec.output_file = args[:nuspec_file]
	   nuspec.file args[:nuspec_file_pattern], "."
	end

	desc "create the nuget package"
	nugetpack :pack, :package_id, :nuspec_file do |nuget, args|
	  package_dir_name = "#{args[:package_id]}.#{@version}"
	  package_dir = File.join(OUTPUT_DIR, package_dir_name)
	  
	  if File.exists? package_dir
		FileUtils.remove_dir package_dir, true
	  end
	  
	  FileUtils.mkdir package_dir
	  	  
	  nuget.command     = NUGET
	  nuget.nuspec      = args[:nuspec_file]
	  nuget.output      = package_dir
	end
	
end