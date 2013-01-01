# Notes

## Examples of URLs Needing Scrubbing

* http://www.democratandchronicle.com/article/20110627/NEWS01/110627014/Charge-against-Emily-Good-videotaping-case-dismissed?odyssey=tab|topnews|text|Local%20News

* http://amiadogroup.github.com/candy/?utm_source=javascriptweekly&utm_medium=email
* http://www.youtube.com/verify_age?display_shmoovie_rating=1&shmoovie_rating=206&shmoovie_rating_type=2&next_url=/watch%3Fv%3D88umaJiKMWA%26feature%3Drelated
* http://www.youtube.com/watch?p=wDT2-jdBtPk&feature=PlayList&v=HJ3YaL8Eh-o
* http://www.youtube.com/watch?v=7SWjV-p1jJU&feature=SeriesPlayList&p=62F7346A301E6B56&index=10
* http://www.youtube.com/watch?v=bf2B4AideIU&feature=feedf
* http://www.youtube.com/watch?v=cvj7p7Clq0c&feature=related
* http://www.youtube.com/watch?v=uixxJtJPVXk&feature=player_embedded
* http://www.youtube.com/watch?v=bf2B4AideIU
* http://youtube.com/watch?v=bf2B4AideIU&feature=feedf


## Remove Google Analytics cruft:

```ruby
Lagrange::DataTypes::URLs.blacklist_parameter("utm_source")
Lagrange::DataTypes::URLs.blacklist_parameter("utm_medium")
Lagrange::DataTypes::URLs.blacklist_parameter("utm_term")
Lagrange::DataTypes::URLs.blacklist_parameter("utm_content")
Lagrange::DataTypes::URLs.blacklist_parameter("utm_campaign")
```


## Normalize YouTube URLs:

```ruby
Lagrange::DataTypes::URLs.add_host_mapping("youtube.com", "www.youtube.com")
Lagrange::DataTypes::URLs.blacklist_parameter("feature", "www.youtube.com")
```


## Normalize Imgur URLs:

```ruby
Lagrange::DataTypes::URLs.add_host_mapping("imgur.com", "i.imgur.com")
```


## Tests:

```ruby
Lagrange::DataTypes::URLs.cleanup("http://blogs.forbes.com/andygreenberg/2011/07/29/undeterred-by-arrests-anonymous-spills-data-from-fbi-contractor-mantech/")
Lagrange::DataTypes::URLs.cleanup("http://YouTube.com/watch?v=bf2B4AideIU&feature=feedf&feature=feedf&utm_source=dhjksdh").to_s
Lagrange::DataTypes::URLs.cleanup("http://somewhere.com/watch?v=bf2B4AideIU&feature=feedf&feature=feedf&utm_source=dhjksdh").to_s
Lagrange::DataTypes::URLs.cleanup("http://reviews.cnet.com/8301-19512_7-10260079-233.html?tag=rtcol;inTheNewsNow").to_s
uri = Addressable::URI.parse("http://reviews.cnet.com/8301-19512_7-10260079-233.html?tag=rtcol;inTheNewsNow")
```


## Possible means for cleaning up param lists?

```ruby
require 'addressable/uri'
require 'cgi'
uri = Addressable::URI.parse("http://www.democratandchronicle.com/article/?x=1&x=2&x=&y=")
params = CGI.parse(uri.query)

uri.query = params.keys.sort.map do |key|
  key_escaped = CGI.escape(key)
  values = params[key]
  values = [values] unless(values.is_a?(Array))
  values.
    map { |val| "#{key_escaped}=#{CGI.escape(val)}"}
end.flatten.join('&')

uri.to_s
```


## Gotchas...

* http://reviews.cnet.com/8301-19512_7-10260079-233.html?tag=rtcol

* http://warofdragons.com/index.php?1&site_id=2874
* http://warofdragons.com/index.php?site_id=2874


* http://wiki.aigamedev.com/Methods/A%2A
* http://wiki.aigamedev.com/Methods/A*

* http://www.nytimes.com/2011/06/06/opinion/06diamond.html?_r=2&hp
* http://www.nytimes.com/2011/06/06/opinion/06diamond.html?_r=2

* http://forum.unity3d.com//viewtopic.php?t=10147
