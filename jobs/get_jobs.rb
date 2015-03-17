require "open-uri"
require 'json'

SCHEDULER.every '2s' do
  jsondata = JSON.parse(open("<url>/api/json?pretty=true", :http_basic_authentication=>['<user>','<pwd>']).read)
  
  jsondata['jobs'].each do |job| 
    jobname = File.basename(job['url'])
    
    begin
      jobinfo = JSON.parse(open("<url>/job/#{jobname}/lastBuild/api/json?pretty=true", :http_basic_authentication=>['<user>','<pwd>']).read)
    rescue OpenURI::HTTPError => e
      #p "skipping #{jobname} because of errors..."
      next
    end
    
    # now process
    if (defined?  jobinfo['fullDisplayName'])
      
      if (jobinfo['building'])
        status = 'warning'
      elsif (jobinfo['result'] =~ /SUCCESS/i) 
        status = 'ok'
      else
        status = 'danger'
      end
      send_event("#{jobname}", { title: "#{jobinfo['fullDisplayName']}", status: "#{status}" })
    end
  end
end

