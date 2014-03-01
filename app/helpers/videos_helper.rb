# -*- encoding: utf-8 -*-

module VideosHelper
	require 'cgi'
	require 'digest/md5'

	def getHtmlVideoList(videoList)
		html = ''
		i = 0
		# html += ''."\n"
		# html += '<div class="itemListWrap bgDashed">' + "\n"
		# html += '<ul class="list cf">' + "\n"

		html += '<ul class="listView cf">' + "\n"
		if !videoList.empty?
			videoList.each{|videoInfo|
				
				html += '<li>' + "\n"
				html += '<a href="/videos/detail/' + i.to_s + '" id="itm0006222">' + "\n"
				html += '<div class="listViewInner">' + "\n"
	
				html += '<div class="listViewImg">' + "\n"
				# html += '<img src="/common/sp/img/action/item.clipped.png" alt="" class="itemClipped">' + "\n"
				html += '<img src="' + videoInfo['image_url'] + '" class="jsLazy" width="104" height="104" style="display: block;">' + "\n"
				html += '</div>' + "\n"
	
				html += '<div class="listViewSummary">' + "\n"
				html += '<ul>' + "\n"
				html += '<li class="itemName">' + "\n"
				html += '<h2>' + videoInfo['name'].truncate(18) + '</h2>' + "\n"
				html += '</li>' + "\n"			
				html += '</ul>' + "\n"
				html += '</div>' + "\n"
	
				html += '</div>' + "\n"
				html += '</a>' + "\n"
				html += '</li>' + "\n"
	
		

				i += 1
			}
		end
		html += '</ul>' + "\n"

		return html
	end

	# def getImageUrlByKeyword(name)
		
	# 	urls = [
	# 		{'keyword' => 'げんしけん', 'url' => 'http://livedoor.blogimg.jp/animekurabu/imgs/d/7/d7da95d0.jpg'},
	# 		{'keyword' => 'さんかれあ', 'url' => 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcRpfkgVaWd5sO8-s-C5f8RmEASQ2zhkQ1w2Pxy0ZkfyA5ZY_YuifA'},
	# 		{"keyword" => "私がモテないのはどう考えてもお前らが悪い！", 'url' => 'https://si0.twimg.com/profile_images/3449899025/3d37d3adcd84f4e3f570364e31b8d40b.jpeg'}
	# 	]
		
	# 	urls.each{|item|
	# 		pattern = item['keyword']
	# 		if name.match(/#{pattern}/)
	# 			return item['url']
	# 		end
	# 	}
	# 	return 'http://www.riviera-re.jp/wordpress/wp-content/themes/riviera/images/tmb_noimage_l.jpg'
	# end

	def getHtmlEncodeResult( result )
		html = ""
		if result
			html = "<h2>encode done</h2>\n"
		else
			html = "<h2>encode failed</h2>\n"
		end
		return html
	end

	def getHtmlVideoOperation( videoInfo )
		html = ''
		if videoInfo['name'].empty?
			html += '<h2>no name</h2>' + "\n"
		else
			html += '<h2>' + videoInfo['name'] + '</h2>' + "\n"
		end
		html += '<ul>' + "\n"
		logger.debug('status:' + videoInfo['status'].to_s)
		if videoInfo['status']==0
			html += '<li>play</li>' + "\n"
			html += '<li><a href="/videos/encode/' + CGI.escape( videoInfo['name'] ) + '/' + videoInfo['format'] + '/' + videoInfo['index'].to_s + '">encode</a></li>' + "\n"
			html += '<li>' + videoInfo['back_up_status'] + '</li>'
			html += '<li><a href="#" id="del" index="' + videoInfo['index'].to_s + '">delete</a></li>' + "\n"
		elsif videoInfo['status']==1
			html += '<li>play</li>' + "\n"
			html += '<li>now encoding</li>' + "\n"
			html += '<li>' + videoInfo['back_up_status'] + '</li>'
			html += '<li>delete</li>' + "\n"
		elsif videoInfo['status']==2
			# html += '<li><a href="/videos/player/' + Digest::MD5.new.update( videoInfo['name'] ).to_s + '">play</a></li>' + "\n"
			html += '<li><a href="/file/' + Digest::MD5.new.update( videoInfo['name'] ).to_s + '.mp4">play</a></li>' + "\n"
			html += '<li>encode</li>' + "\n"
			html += '<li>' + videoInfo['back_up_status'] + '</li>'
			html += '<li><a href="#" id="del" index="' + videoInfo['index'].to_s + '">delete</a></li>' + "\n"
		end
		html += '</ul>' + "\n"
		return html
	end
end