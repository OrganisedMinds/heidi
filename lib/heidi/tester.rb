class Heidi
  class Tester
    def self.test(project, build_root)
      log = File.open(File.join(build_root, "test.log"), File::CREAT|File::APPEND|File::WRONLY)
      tests_failed = false

      project.test_hooks.each do |hook|
        next if tests_failed == true

        res = hook.perform(build_root)
        if res.S?.to_i != 0
          log.puts res.err
          tests_failed = true
        else
          log.puts res.out
        end
      end

      return tests_failed ? false : true
    end
  end
end
