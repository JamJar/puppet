test_name "should create cron"

tmpuser = "pl#{rand(999999).to_i}"
tmpfile = "/tmp/cron-test-#{Time.new.to_i}"

create_user = "user { '#{tmpuser}': ensure => present, managehome => false }"
delete_user = "user { '#{tmpuser}': ensure => absent,  managehome => false }"

agents.each do |host|
    step "ensure the user exist via puppet"
    apply_manifest_on host, create_user

    step "apply the resource on the host using puppet resource"
    on(host, puppet_resource("cron", "crontest", "user=#{tmpuser}",
                  "command=/bin/true", "ensure=present")) do
        fail_test "didn't notice creation of the cron stuff" unless
            stdout.include? 'created'
    end

    step "verify that crontab -l contains what you expected"
    run_cron_on(host, :list, tmpuser) do
        fail_test "didn't find the command as expected" unless
            stdout.include? "* * * * * /bin/true"
    end

    step "remove the crontab file for that user"
    run_cron_on(host, :remove, tmpuser)

    step "remove the user from the system"
    apply_manifest_on host, delete_user
end
