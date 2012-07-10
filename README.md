## Paperclip Captions
This requires the Paperclip Gem plugin.

### Instructions
1.  Put the file into ./lib/paperclip_processors/
2.  Modify your model like so:
3.  Note:  I'm using Mongoid::Paperclip 

```ruby

Class Foo
  include Mongoid::Paperclip
    
  field :caption_top, :type => String
  field :caption_top_font, :type => String
  field :caption_top_font_size, :type => Integer

  field :caption_bottom, :type => String
  field :caption_bottom_font, :type => String
  field :caption_bottom_font_size, :type => Integer

  has_mongoid_attached_file :image, :processors => [:captions]

end
```


### Explanation
line 21 - 25:  Pulling the instance values from the object (in the example case "Foo"
line 42 - 56:  Creating the top caption and merging it into the image
line 58 - 74:  Creating the bottom caption and merging it into the image
line 76 - 85:  Resizing the image if necessary

Email me at dwang@udfi.biz for questions/comments!  Fork and post a merge request for bug fixes!

