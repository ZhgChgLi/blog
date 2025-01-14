#!/usr/bin/env ruby
#
require 'net/http'
require 'nokogiri'
require 'uri'


def load_medium_followers(url, limit = 10)
  return 0 if limit.zero?

  uri = URI(url)
  response = Net::HTTP.get_response(uri)
  case response
  when Net::HTTPSuccess then
      document = Nokogiri::HTML(response.body)

      follower_count_element = document.at('span.pw-follower-count > a')
      follower_count = follower_count_element&.text&.split(' ')&.first

      return follower_count || 0
  when Net::HTTPRedirection then
    location = response['location']
    return load_medium_followers(location, limit - 1)
  else
      return 0
  end
end

$medium_url = "https://medium.com/@zhgchgli"
$medium_followers = load_medium_followers($medium_url)

$medium_followers = 1000 if $medium_followers == 0
$medium_followers = $medium_followers.to_s.reverse.scan(/\d{1,3}/).join(',').reverse

Jekyll::Hooks.register :posts, :pre_render do |post|
  slug = post.data['slug']
  post.content = post.content.gsub(/(_\[Post\])(.*)(converted from Medium by \[ZMediumToMarkdown\])(.*)(\._)/, '')

  headerHTML = <<-HTML
  <widgetic id="64ce7263ecb2a197598b4567" resize="fill-width" height="30" autoscale="on"></widgetic><script async src="https://widgetic.com/sdk/sdk.js"></script>
  HTML

  footerHTML = <<-HTML
  \r\n\r\n===
  \r\n\r\n本文首次發表於 Medium ➡️ [**前往查看**](https://medium.com/p/#{slug}){:target=\"_blank\"}\r\n

  HTML

  if post.data['categories'].any? { |category| category.match(/遊記/) }
  footerHTML += <<-HTML
  <a href="https://www.kkday.com/zh-tw?cid=19365" target="_blank">如果這篇文章對您有幫助，歡迎使用我的 推廣連結 選購 KKday 商品、行程，我將獲得部分收益，持續更多旅遊創作，謝謝：</a>
  <ins class="kkday-product-media" data-oid="870" data-amount="6" data-origin="https://kkpartners.kkday.com"></ins>
  <script type="text/javascript" src="https://kkpartners.kkday.com/iframe.init.1.0.js"></script>
  HTML
  end

  footerHTML += <<-HTML
  <a href="https://www.buymeacoffee.com/zhgchgli" target="_blank"><img src="https://img.buymeacoffee.com/button-api/?text=Buy me a beer&emoji=🍺&slug=zhgchgli&button_colour=FFDD00&font_colour=000000&font_family=Bree&outline_colour=000000&coffee_colour=ffffff" alt="Buy me a beer"/></a>
  <widgetic id="64ce71d5ecb2a165598b4567" resize="fill-width" height="30" autoscale="on"></widgetic><script async src="https://widgetic.com/sdk/sdk.js"></script>
  <div onclick="this.style.position='';" style="text-align: center; position: -webkit-sticky; position: sticky; bottom: 0; z-index: 1; margin: 0 -1rem; padding: 5px; background: var(--main-bg); border-bottom: 1px solid var(--main-border-color);transition: all .2s ease-in-out;"><a href="#{$medium_url}" target="_blank" style="display:inline-flex;align-items:center;justify-content:center;gap:10px;padding:10px 20px;font-size:16px;font-weight:bold;color:#ffffff;background-color:#00ab6c;border-radius:5px;text-decoration:none;box-shadow:0 4px 6px rgba(0,0,0,0.1);transition:all 0.3s ease;cursor:pointer;" onmouseover="this.style.backgroundColor='#008f5a';this.style.transform='translateY(-2px)';this.style.boxShadow='0 6px 10px rgba(0,0,0,0.15)';" onmouseout="this.style.backgroundColor='#00ab6c';this.style.transform='translateY(0)';this.style.boxShadow='0 4px 6px rgba(0,0,0,0.1)';">Follow Me on Medium <span style="font-size:14px;color:rgba(255,255,255,0.9);font-weight:normal;opacity:0.9;">#{$medium_followers}+ Followers</span></a></div>
  HTML


  post.content = headerHTML + post.content + footerHTML
end

Jekyll::Hooks.register :site, :pre_render do |site|

  tagline = site.config['tagline']
  
  followMe = <<-HTML
  <a href="https://medium.com/@zhgchgli" target="_blank" style="display: block;text-align: center;font-style: normal;/* text-decoration: underline; */font-size: 1.2em;color: var(--heading-color);">#{$medium_followers}+ Followers on Medium</a>
  HTML

  site.config['tagline'] = "#{followMe}"
  site.config['tagline'] += tagline
end