## Paperclip Captions
This requires the Paperclip Gem plugin.

### Instructions
1.  Put the file into ./lib/paperclip_processors/
2.  Modify your model like so:
3.  Note:  I'm using Mongoid::Paperclip 

```ruby

Class Foo
    include Mongoid::Paperclip
    has_mongoid_attached_file :image, :processors => [:captions]
end
```


