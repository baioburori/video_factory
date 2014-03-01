# -*- encoding: utf-8 -*-
require 'cgi'
require 'digest/md5'
require 'kconv'
require 'net/http'
require 'uri'

class VideosController < ApplicationController
  ENCODED_DIR = 'I:\\Users\\nakagawa\\Documents\\rails\\video_factory\\public\\file'
  NOT_WATCHED_DIR = 'I:\\Users\\nakagawa\\Videos\\not_watched'
  HAND_BRAKE = '"C:\\Program Files\\Handbrake\\HandBrakeCLI.exe"'
  PRESET = 'Android'
  # PRESET = 'iPod'
  IMAGE_API_URL = 'http://ajax.googleapis.com/ajax/services/search/images'

  BACK_UP_CONF = 'I:\\Users\\nakagawa\\Documents\\jscript\\fb_setting.json'

  def getVideoList

    Dir.chdir( NOT_WATCHED_DIR );
    filenames = Dir.glob( '*' )             # 全てのファイル名をシフトJISコードで取得
    #str = ''
    videoList = []
    i = 0
    filenames.each do |f|
      #str += "****<br>"
      #str += f + '<br>'                                 # ShiftJISのまま表示
      #str += f.kconv(Kconv::UTF8, Kconv::SJIS) + '<br>' # ShiftJIS から UTF-8 に変換し表示
      # videoInfo = {'name' => f.kconv(Kconv::UTF8, Kconv::SJIS)}
      fileNameWithFormat = f
      # fileNameWithFormat = f.kconv(Kconv::UTF8, Kconv::SJIS)
      # fileNameWithFormat = "test.ts"
      format = getFormat( fileNameWithFormat );
      if format=="ts" || format=="mp4" then
        fileName = removeFormat( fileNameWithFormat );
        # encoded = File.exist?( NOT_WATCHED_DIR + fileName + '.mp4' );
        # logger.debug( 'name:' + ENCODED_DIR + '\\' + fileName + '.mp4' );
        # logger.debug( 'converted_name:' + ENCODED_DIR + '\\' + Digest::MD5.new.update(fileName).to_s + '.mp4' );
        outputFileExist = File.exist?( ENCODED_DIR + '\\' + Digest::MD5.new.update(fileName).to_s + '.mp4' );
        rockFileExist = File.exist?( ENCODED_DIR + '\\' + Digest::MD5.new.update(fileName).to_s + '.mp4.lock' );
        if outputFileExist
          if rockFileExist
            status = 1
          else
            status = 2
          end
        else
          status = 0
        end
        videoInfo = {
                      'name' => fileName, 
                      'format' => format, 
                      'status' => status, 
                      'index' => i,
                      'image_url' => getImageUrlByKeyword(fileName) 
                    }
        i += 1
        videoList.push videoInfo
      # else format=="mp4" then

      end
    end
    return videoList
  end

  def getVideoInfo(index)

    Dir.chdir( NOT_WATCHED_DIR );
    filenames = Dir.glob(["*.ts", "*.mp4"])             # 全てのファイル名をシフトJISコードで取得
    videoList = []
      fileNameWithFormat = filenames[index]
      # logger.debug('filename:' + fileNameWithFormat)
      format = getFormat( fileNameWithFormat );
      if format=="ts" || format=="mp4" then
        fileName = removeFormat( fileNameWithFormat );
        outputFileExist = File.exist?( ENCODED_DIR + '\\' + Digest::MD5.new.update(fileName).to_s + '.mp4' );
        rockFileExist = File.exist?( ENCODED_DIR + '\\' + Digest::MD5.new.update(fileName).to_s + '.mp4.lock' );
        if outputFileExist
          if rockFileExist
            status = 1
          else
            status = 2
          end
        else
          status = 0
        end
        videoInfo = {
                      'name' => fileName, 
                      'format' => format, 
                      'status' => status, 
                      'index' => index,
                      'image_url' => getImageUrlByKeyword(fileName),
                      'back_up_status' => getBackUpStatus(fileName)
                    }
      else 
      end
    return videoInfo
  end

  def getImageUrlByKeyword(name)
    require 'json'

    # find the image url in DB
    imageUrl = getImageUrlInDatabase(name)

    if imageUrl.blank?

      # request the image url from Google API
      # url = URI.parse(IMAGE_API_URL + '?q=' + CGI.escape(name) + '&v=1.0&imgsz=small')
      # res = Net::HTTP.start(url.host, url.port) {|http|
      #   http.get('/ajax/services/search/images?q=' + CGI.escape(name) + '&v=1.0&imgsz=small')
      # }

      # DBに登録されてなかったら常にノーイメージ画像を返す
      if true
      # if JSON.parse(res.body)['responseData'].blank? || JSON.parse(res.body)['responseData']['results'].blank?
        return 'http://www.riviera-re.jp/wordpress/wp-content/themes/riviera/images/tmb_noimage_l.jpg'
      else
        imageList = JSON.parse(res.body)['responseData']['results']
        prng = Random.new
        index = prng.rand(imageList.length)
        return imageList[index]['url']
      end

    else
      return imageUrl
    end
  end

  def getImageUrlInDatabase(name)
    # iu = ImageUrl.find_by_query(name)
    imageUrlList = ImageUrl.find(:all)
    if imageUrlList.blank?
    else
      # logger.debug('url:' + iu.url)
      imageUrlList.each{|imageUrl|
        # logger.debug('query:'+imageUrl.query)
        if /#{imageUrl.query}/ =~ name
          # logger.debug('matched')
          return imageUrl.url
        else
          # logger.debug('do not matched')
        end
      }
    end
    return nil
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

  def player
    
    name = CGI.unescape( params[:name] )
    # logger.debug( 'name:' + name );

    @source = '/file/' + name + '.mp4'
  end


  def encode
    name = params[:name]
    format = params[:format]
    # render :text => "name = #{params[:name]}"
    @index = params[:index].to_i
    @result = encodeVideo( name, format )
  end

  def encodeVideo( name,format )
    # logger.debug('format:' + format)
    convertedName = name.kconv(Kconv::SJIS, Kconv::UTF8)
    srcPath = NOT_WATCHED_DIR + '\\' + convertedName + '.' + format
    dstPath = ENCODED_DIR + '\\' + Digest::MD5.new.update( name ).to_s + '.mp4'
    lockFile = dstPath + '.lock'
    # logger.debug( 'src:' + srcPath );
    # logger.debug( 'dst:' + dstPath );

    File.open( lockFile, "w").close()

    if format=='ts'
      result = spawn(HAND_BRAKE + ' -i ' + srcPath +' -o ' + dstPath + ' --preset '+ PRESET + ' & rm ' + lockFile)
    elsif format=='mp4'
      result = spawn( 'cp ' + srcPath + ' ' + dstPath + ' & rm ' + lockFile )
    end
    return result
  end

  def list
    @videoList = getVideoList
  end

  def detail
    @videoInfo = getVideoInfo(params[:index].to_i)
    # @test = isBackedUp()
  end

  def delete
    videoList = getVideoList
    index = params[:index].to_i
    if !videoList.empty?
      videoInfo = videoList[index]
    else
    end
    deleteVideo( videoInfo['name'], videoInfo['format'] )
  end

  def deleteVideo( name, format )
    targetPath = NOT_WATCHED_DIR + '\\' + name + '.' + format
    encodedTargetPath = ENCODED_DIR + '\\' + Digest::MD5.new.update( name ).to_s + '.mp4'



    if File.exist?( targetPath )
      # spawn( 'rm ' + targetPath )
      File.delete( targetPath )
    end
    if File.exist?( encodedTargetPath)
      # spawn( 'rm ' + encodedTargetPath )
      File.delete( encodedTargetPath )
    end
  end

  # ビデオがバックアップされているか判定する
  def getBackUpStatus(fileName)
    #　バックアップ対象ビデオか調べる
    backUpConf = File.open(BACK_UP_CONF, 'r')
    # confJson = JSON.parse(backUpConf.read.kconv(Kconv::SJIS, Kconv::UTF8))
    confJson = JSON.parse(backUpConf.read.kconv(Kconv::UTF8, Kconv::SJIS))
    backUpConf.close

    confJson['copy_list'].each do |needCopy|
      searchFileName = needCopy['search_file_name']
      # if fileName =~ /宇宙兄弟/
      if fileName.match(/#{searchFileName}/)
        # 録画フォルダのビデオのサイズを取得
        capturedFileSize = File.size(NOT_WATCHED_DIR + '\\' + fileName + '.ts')
        # return confJson['target_path'] + '\\' + needCopy['target_directory_name']
        Dir.chdir(confJson['target_path'] + '\\' + needCopy['target_directory_name'])
        videoList = Dir.glob('*')
        videoList.each do |videoName|
          # バックアップフォルダのビデオのサイズを取得
          backedUpFileSize = File.size(confJson['target_path'] + '\\' + needCopy['target_directory_name'] + '\\' + videoName)
          if capturedFileSize == backedUpFileSize
            return 'backed up'
          end
        end

        return 'not backed up'
      end
    end
    return '-'
  end
end
