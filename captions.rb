module Paperclip
  class Captions < Processor
    # Handles watermarking of images that are uploaded.
    attr_accessor :current_geometry, :target_geometry, :format, :whiny, :convert_options, :watermark_path, :overlay, :position

    def initialize file, options = {}, attachment = nil
      super
      geometry          = options[:geometry]
      @file             = file
      @crop             = geometry[-1,1] == '#'
      @target_geometry  = Geometry.parse geometry
      @current_geometry = Geometry.from_file @file
      @convert_options  = options[:convert_options]
      @whiny            = options[:whiny].nil? ? true : options[:whiny]
      @format           = options[:format]
      @watermark_path   = options[:watermark_path]
      @position         = options[:position].nil? ? "SouthEast" : options[:position]
      @overlay          = options[:overlay].nil? ? true : false
      @current_format   = File.extname(@file.path)
      @basename         = File.basename(@file.path, @current_format)
      @instance         = attachment.instance
      @bottom_font_size = @instance.caption_bottom_font_size.nil? ? 50 : @instance.caption_bottom_font_size
      @top_font_size    = @instance.caption_top_font_size.nil? ? 50 : @instance.caption_top_font_size
      @caption_bottom   = @instance.caption_bottom.nil? ? " " : @instance.caption_bottom
      @caption_top      = @instance.caption_top.nil? ? " " : @instance.caption_top
    end

    # Returns true if the +target_geometry+ is meant to crop.
    def crop?
      @crop
    end

    # Returns true if the image is meant to make use of additional convert options.
    def convert_options?
      not @convert_options.blank?
    end

    # Performs the conversion of the +file+ into a watermark. Returns the Tempfile
    # that contains the new image.
    def make

      if !@caption_top.empty?
        ## build caption top
        caption_top = Tempfile.new([@basename, ".png"])
        caption_top.binmode

        command = "montage"
        params = "-background none -fill white -font #{Rails.root}/app/assets/stylesheets/fonts/futura_condensed_medium.ttf -pointsize #{@top_font_size} label:\"#{escape @caption_top}\" +set label -shadow -background none -geometry +6+6 #{get_path(caption_top)}"

        run_image_magick command, params

        command = "composite"
        params = "-gravity north -geometry +0+3 #{get_path(caption_top)} #{fromfile} #{fromfile}"

        run_image_magick command, params
      end

      if !@caption_bottom.empty?

        ## build caption bottom
        caption_bottom = Tempfile.new([@basename, ".png"])
        caption_bottom.binmode

        command = "montage"
        params = "-background none -fill white -font #{Rails.root}/app/assets/stylesheets/fonts/futura_condensed_medium.ttf -pointsize #{@bottom_font_size} label:\"#{escape @caption_bottom}\" +set label -shadow -background none -geometry +6+6 #{get_path(caption_bottom)}"

        run_image_magick command, params

        ## build final with caption top
        command = "composite"
        params = "-gravity south -geometry +0+3 #{get_path(caption_bottom)} #{fromfile} #{fromfile}"

        run_image_magick command, params
      end

      ## resize the sucker
      dst = Tempfile.new([@basename, ".png"])
      dst.binmode

      command = "convert"
      params = "#{fromfile} #{transformation_command} #{get_path(dst)}"

      run_image_magick command, params

      dst
    end

    def escape(string)
      string.gsub("\\","\\\\\\\\").gsub('"','\\\\"').gsub('$', '\$')
    end

    def run_image_magick(command, params)
      begin
        success = Paperclip.run(command, params)
      rescue PaperclipCommandLineError
        raise PaperclipError, "There was an error processing the watermark resize for #{@basename}" if @whiny
      end
    end

    def fromfile
      "\"#{ File.expand_path(@file.path) }[0]\""
    end

    def get_path(destination)
      "\"#{ File.expand_path(destination.path) }[0]\""
    end

    def transformation_command
      scale, crop = @current_geometry.transformation_to(@target_geometry, crop?)
      trans = "-resize \"#{scale}\""
      #trans << " -crop \"#{crop}\" +repage" if crop
      #trans << " #{convert_options}" if convert_options?
      trans
    end


  end

end
