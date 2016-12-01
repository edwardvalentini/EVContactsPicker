PODREPO = "trunk"

task :version do
  git_remotes = `git remote`.strip.split("\n")

  if git_remotes.count > 0
    puts "-- fetching version number from github"
    sh 'git fetch'

    remote_version = remote_spec_version
  end

  if remote_version.nil?
    puts "There is no current released version. You're about to release a new Pod."
    version = "0.0.1"
  else
    puts "The current released version of your pod is " + remote_spec_version.to_s()
    version = suggested_version_number
  end

  new_version_number = version
  replace_version_number(new_version_number)
end

desc "Release a new version of the Pod without replacing version number"
task :release_no_version do
  perform_release
end

desc "Release a new version of the Pod"
task :release do
  puts "* Running version"
  sh "rake version"
  perform_release
end

def perform_release
  unless ENV['SKIP_CHECKS']
    if `git tag`.strip.split("\n").include?(spec_version)
      $stderr.puts "[!] A tag for version `#{spec_version}' already exists. Change the version in the podspec"
      exit 1
    end

    puts "You are about to release `#{spec_version}`"
  end

  # puts "* Running tests"
  # sh "rake test"

  branch = `git rev-parse --abbrev-ref HEAD`.chomp

  # Then release
  sh "git commit #{podspec_path} -m 'Release #{spec_version}'"
  sh "git tag -a #{spec_version} -m 'Release #{spec_version}'"
  sh "git push origin #{branch}"
  sh "git push origin --tags"
  #sh "pod repo push #{PODREPO} #{podspec_path} --allow-warnings"
  sh "pod trunk push #{podspec_path} --allow-warnings" # --verbose"
end

# @return [Pod::Version] The version as reported by the Podspec.
#
def spec_version
  require 'cocoapods'
  spec = Pod::Specification.from_file(podspec_path)
  spec.version
end

# @return [Pod::Version] The version as reported by the Podspec from remote.
#
def remote_spec_version
  require 'cocoapods-core'

  branch = `git rev-parse --abbrev-ref HEAD`.chomp
  if spec_file_exist_on_remote?
    remote_spec = eval(`git show origin/"#{branch}":#{podspec_path}`)
    remote_spec.version
  else
    nil
  end
end

# @return [Bool] If the remote repository has a copy of the podpesc file or not.
#
def spec_file_exist_on_remote?
  branch = `git rev-parse --abbrev-ref HEAD`.chomp
  test_condition = `if git rev-parse --verify --quiet origin/"#{branch}":#{podspec_path} >/dev/null;
  then
  echo 'true'
  else
  echo 'false'
  fi`

  'true' == test_condition.strip
end

# @return [String] The relative path of the Podspec.
#
def podspec_path
  podspecs = Dir.glob('*.podspec')
  if podspecs.count == 1
    podspecs.first
  else
    raise "Could not select a podspec"
  end
end

# @return [String] The suggested version number based on the local and remote version numbers.
#
def suggested_version_number
  if spec_version != remote_spec_version
    spec_version.to_s()
  else
    next_version(spec_version).to_s()
  end
end

# @param  [Pod::Version] version
#         the version for which you need the next version
#
# @note   It is computed by bumping the last component of the versino string by 1.
#
# @return [Pod::Version] The version that comes next after the version supplied.
#
def next_version(version)
  version_components = version.to_s().split(".");
  last = (version_components.last.to_i() + 1).to_s
  version_components[-1] = last
  Pod::Version.new(version_components.join("."))
end

# @param  [String] new_version_number
#         the new version number
#
# @note   This methods replaces the version number in the podspec file with a new version number.
#
# @return void
#
def replace_version_number(new_version_number)
  text = File.read(podspec_path)
  text.gsub!(/(s.version( )*= ")#{spec_version}(")/, "\\1#{new_version_number}\\3")
  File.open(podspec_path, "w") { |file| file.puts text }
end

def workspace
  return 'EVContactsPicker.xcworkspace'
end

def configuration
  return 'Debug'
end

def targets
  return [
    :ios,
  ]
end

def schemes
  return {
    ios: 'EVContactsPicker-Example'
  }
end

def sdks
  return {
    ios: 'iphonesimulator10.1'
  }
end

def devices
  return {
    ios: "name='iPhone 7 Plus'"
  }
end

def xcodebuild_in_demo_dir(tasks, platform, xcpretty_args: '')
  sdk = sdks[platform]
  scheme = schemes[platform]
  destination = devices[platform]

  Dir.chdir('Example') do
    sh "set -o pipefail && xcodebuild -workspace '#{workspace}' -scheme '#{scheme}' -configuration '#{configuration}' -sdk #{sdk} -destination #{destination} #{tasks} | xcpretty -f `xcpretty-travis-formatter` -c #{xcpretty_args}"
  end
end

desc 'Build the Example app.'
task :build do
  xcodebuild_in_demo_dir 'build', :ios
end

desc 'Clean build directory.'
task :clean do
  xcodebuild_in_demo_dir 'clean', :ios
end

desc 'Build, then run tests.'
task :test do
  targets.map { |platform| xcodebuild_in_demo_dir 'build test', platform, xcpretty_args: '--test' }
  sh "killall Simulator"
end
