require "bundler/setup"
Bundler.require(:default)
require "pp"
require "json"
require "time"

api_photo = JSON.parse(File.read("photo.json"))
api_image = api_photo["images"].max_by{|image| image["width"] }

tags = api_photo["tags"]["data"]

comments = api_photo["comments"]["data"]
comments.each do |comment|
  # puts comment["from"]["name"]
  # puts comment["message"]
  # puts Time.parse(comment["created_time"])
  # puts
end

# save to file

def read_data
  str = %x[exiv2 -eX photo.jpg && cat photo.xmp]
  %x[rm photo.xmp]
  str
end

# start fresh
FileUtils.cp("photo_original.jpg", "photo.jpg")

image = Exiv2::ImageFactory.open("photo.jpg")
image.read_metadata

image.xmp_data["Xmp.dc.description"] = api_photo["name"]
image.xmp_data["Xmp.dc.creator"] = api_photo["from"]["name"]
image.xmp_data["Xmp.xmp.ModifyDate"] = Time.parse(api_photo["created_time"]).iso8601
image.xmp_data["Xmp.mwg-rs.Regions/mwg-rs:AppliedToDimensions/stDim:w"] = api_image["width"].to_s
image.xmp_data["Xmp.mwg-rs.Regions/mwg-rs:AppliedToDimensions/stDim:h"] = api_image["height"].to_s
image.xmp_data["Xmp.mwg-rs.Regions/mwg-rs:AppliedToDimensions/stDim:unit"] = "pixel"
image.xmp_data["Xmp.mwg-rs.Regions/mwg-rs:RegionList"] = ""
tags.each_with_index do |tag, j|
  i = j + 1
  image.xmp_data["Xmp.mwg-rs.Regions/mwg-rs:RegionList[#{i}]/mwg-rs:Name"] = tag["name"]
  image.xmp_data["Xmp.mwg-rs.Regions/mwg-rs:RegionList[#{i}]/mwg-rs:Type"] = "Face"
  image.xmp_data["Xmp.mwg-rs.Regions/mwg-rs:RegionList[#{i}]/mwg-rs:Area/stArea:x"] = (tag["x"] / 100.0).to_s
  image.xmp_data["Xmp.mwg-rs.Regions/mwg-rs:RegionList[#{i}]/mwg-rs:Area/stArea:y"] = (tag["y"] / 100.0).to_s
  image.xmp_data["Xmp.mwg-rs.Regions/mwg-rs:RegionList[#{i}]/mwg-rs:Area/stArea:unit"] = "normalized"
end

image.write_metadata

puts read_data
