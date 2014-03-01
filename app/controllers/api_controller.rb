class ApiController < ApplicationController
  def list
  	render :json => getVideoList
  end



  def getVideoList
  	require 'kconv'
  	Dir.chdir( 'I:\\Users\\nakagawa\\Videos\\not_watched' );
  	filenames = Dir.glob( '*' )             # 全てのファイル名をシフトJISコードで取得
  	#str = ''
  	videoList = {'response' => []}
	filenames.each do |f|
  		#str += "****<br>"
  		#str += f + '<br>'                                 # ShiftJISのまま表示
  		#str += f.kconv(Kconv::UTF8, Kconv::SJIS) + '<br>' # ShiftJIS から UTF-8 に変換し表示
  		# videoInfo = {'name' => f.kconv(Kconv::UTF8, Kconv::SJIS)}
  		fileNameWithFormat = f
  		# fileNameWithFormat = f.kconv(Kconv::UTF8, Kconv::SJIS)
  		# fileNameWithFormat = "test.ts"
  		format = getFormat( fileNameWithFormat );
  		if format=="ts" then
  			fileName = removeFormat( fileNameWithFormat );
  			encoded = File.exist?( 'I:\\Users\\nakagawa\\Videos\\not_watched\\' + fileName + '.mp4' );
  			videoInfo = {'name' => fileName, 'encoded' => encoded }
  			videoList['response'].push videoInfo
  		end
	end
	return videoList
  end

  def removeFormat( fileNameWithFormat )
  	fileName = ''
  	# str = 'http://instagram.com/p/hoge/'
	fileName = fileNameWithFormat.match(%r{(.+)\..+})[1]
  	return fileName
  end

  def getFormat( fileNameWithFormat )
  	format = fileNameWithFormat.match(%r{.+\.(.+)})[1]
  	return format
  end

  def encodeVideo(  )
end
