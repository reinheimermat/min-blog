namespace :test do
  desc "Open SimpleCov coverage report"
  task :coverage do
    system("xdg-open coverage/index.html")
  end
end
