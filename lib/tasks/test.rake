namespace 'test' do
  desc 'Test the schema against the migrations'
  task 'schema' => :environment do
    Rake::Task['db:environment:set'].invoke
    Rake::Task['db:migrate:reset'].invoke
    sh 'git diff --exit-code -w db/schema.rb'
  end
end
