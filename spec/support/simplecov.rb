if(ENV['USING_COVERAGE'].to_i > 0)
  BASE_DIR = File.expand_path(File.join(File.dirname(__FILE__), '../..'))
  def expand_path(p)
    return Dir[File.expand_path(File.join(BASE_DIR, p))]
  end
  CORE_PATHS=[
    expand_path("lib/lagrange/*.rb"),
    expand_path("lib/lagrange.rb"),
  ].flatten
  DATA_TYPES_PATHS=[
    expand_path("lib/lagrange/data_types/**/*.rb")
  ].flatten
  MODELS_PATHS=[
    expand_path("lib/lagrange/models/**/*.rb")
  ].flatten
  MODULES_PATHS=[
    expand_path("lib/lagrange/modules/**/*.rb")
  ].flatten
  TEST_PATHS=[
    expand_path("features/**/*.rb"),
    expand_path("spec/**/*.rb")
  ].flatten

  require 'simplecov'
  SimpleCov.start do
    add_group "Core" do |src_file|
      CORE_PATHS.map { |p| src_file.filename.start_with?(p) }.select { |tf| tf }.count != 0
    end
    add_group "Data Types" do |src_file|
      (DATA_TYPES_PATHS.map { |p| src_file.filename.start_with?(p) }.select { |tf| tf }.count != 0)
    end
    add_group "Models" do |src_file|
      (MODELS_PATHS.map { |p| src_file.filename.start_with?(p) }.select { |tf| tf }.count != 0)
    end
    add_group "Modules" do |src_file|
      (MODULES_PATHS.map { |p| src_file.filename.start_with?(p) }.select { |tf| tf }.count != 0)
    end
    add_group "Tests" do |src_file|
      (TEST_PATHS.map { |p| src_file.filename.start_with?(p) }.select { |tf| tf }.count != 0)
    end
  end
end
