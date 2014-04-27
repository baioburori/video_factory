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
  OPTION = ' -e x264 -q 22.0 -r 29.97 --cfr -a 1 -E faac -B 128 -6 dpl2 -R Auto -D 0.0 --audio-copy-mask aac,ac3,dtshd,dts,mp4 --audio-fallback ffac3 -f mp4 -X 720 -Y 576 --loose-anamorphic --modulus 2 --x264-preset medium --h264-profile main --h264-level 3.0'
  IMAGE_API_URL = 'http://ajax.googleapis.com/ajax/services/search/images'

  BACK_UP_CONF = 'I:\\Users\\nakagawa\\Documents\\jscript\\fb_setting.json'
  SLEEP_COMMAND = 'rundll32.exe PowrProf.dll,SetSuspendState'

  def getVideoList

    Dir.chdir( NOT_WATCHED_DIR );
    filenames = Dir.glob( '*' )             # 全てのファイル名をシフトJISコードで取得
    videoList = []
    i = 0
    filenames.each do |f|
      # p 'f:' + f
      fileNameWithFormat = f
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
                      'escaped_name' => CGI.escape(fileNameWithFormat),
                      'image_url' => getImageUrlByKeyword(fileName) 
                    }
        i += 1
        videoList.push videoInfo

      end
    end
    return videoList
  end

  def getVideoInfo(escapedName, format)

    Dir.chdir( NOT_WATCHED_DIR );
    videoList = []
      p 'escapedName:' + escapedName
      fileName = URI.unescape(escapedName)
      if format=="ts" || format=="mp4" then
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
                      'escaped_name' => escapedName + '.' + format,
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

      # DBに登録されてなかったら常にノーイメージ画像を返す
      if true
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
    imageUrlList = ImageUrl.find(:all)
    if imageUrlList.blank?
    else
      imageUrlList.each{|imageUrl|
        if /#{imageUrl.query}/ =~ name
          return imageUrl.url
        else
        end
      }
    end
    return nil
  end

  def removeFormat( fileNameWithFormat )
    fileName = ''
  fileName = fileNameWithFormat.match(%r{(.+)\..+})[1]
    return fileName
  end

  def getFormat( fileNameWithFormat )
    p 'fileNameWithFormat:' + fileNameWithFormat
    format = fileNameWithFormat.match(%r{.+\.(.+)})[1]
    return format
  end

  def player
    
    name = URI.unescape( params[:name] )
    @source = '/file/' + name + '.mp4'
  end


  def encode
    @escaped_name = URI.escape(params[:name] + params[:format])
    @result = encodeVideo( params[:name], params[:format] )
  end

  def encodeVideo( name,format )
    convertedName = name.kconv(Kconv::SJIS, Kconv::UTF8)
    srcPath = NOT_WATCHED_DIR + '\\' + convertedName + '.' + format
    dstPath = ENCODED_DIR + '\\' + Digest::MD5.new.update( name ).to_s + '.mp4'
    lockFile = dstPath + '.lock'

    File.open( lockFile, "w").close()

    if format=='ts'
      result = spawn(HAND_BRAKE + ' -i ' + srcPath +' -o ' + dstPath + OPTION + ' & rm ' + lockFile)
    elsif format=='mp4'
      result = spawn( 'cp ' + srcPath + ' ' + dstPath + ' & rm ' + lockFile )
    end
    return result
  end

  def list
    @videoList = getVideoList
  end

  def detail
    @videoInfo = getVideoInfo(params[:escaped_name], params[:format])
    @escaped_name = params[:escaped_name] + '.' + params[:format]
  end

  def delete
    deleteVideo( URI.unescape(params[:escaped_name]), params['format'] )
  end

  # スリープのコントローラ
  def sleep
    @result = spawn(SLEEP_COMMAND)
  end
  def deleteVideo( name, format )
    targetPath = NOT_WATCHED_DIR + '\\' + name + '.' + format
    encodedTargetPath = ENCODED_DIR + '\\' + Digest::MD5.new.update( name ).to_s + '.mp4'

    if File.exist?( targetPath )
      File.delete( targetPath )
    end
    if File.exist?( encodedTargetPath)
      File.delete( encodedTargetPath )
    end
  end

  # ビデオがバックアップされているか判定する
  def getBackUpStatus(fileName)
    #　バックアップ対象ビデオか調べる
    backUpConf = File.open(BACK_UP_CONF, 'r')
    confJson = JSON.parse(backUpConf.read.kconv(Kconv::UTF8, Kconv::SJIS))
    backUpConf.close

    confJson['copy_list'].each do |needCopy|
      searchFileName = needCopy['search_file_name']
      if fileName.match(/#{searchFileName}/)
        # 録画フォルダのビデオのサイズを取得
        capturedFileSize = File.size(NOT_WATCHED_DIR + '\\' + fileName + '.ts')
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
