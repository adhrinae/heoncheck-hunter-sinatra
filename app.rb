require 'sinatra'

get '/' do
  erb :index
end

get '/search' do
  book_title = params[:title]

  @results = SearchBook.new(book_title).find
  erb :result, locals: { results: @results }
end

class SearchBook
  require "uri"
  require "mechanize"

  # 매장 리스트
  STORE_LISTS = { 'gangnam' => '강남점', 'sinchon' => '신촌점', 'geondae' => '건대점',
                  'nowon' => '노원점', 'daehakro' => '대학로점', 'suyu' => '수유점', 'sillim' => '신림점',
                  'yeonsinnae' => '연신내점', 'jamsil' => '잠실롯데월드타워점',
                  'sincheon' => '잠실신천점', 'jongno' => '종로점', 'hapjeong' => '합정점' }.freeze

  # 매장 방문 URI
  STORE_URI = "http://off.aladin.co.kr/usedstore/wstoremain.aspx?offcode="

  # 검색 기본 URI
  SEARCH_URI = "http://off.aladin.co.kr/usedstore/wsearchresult.aspx?SearchWord="

  def initialize(book)
    @book = book.encode('euc-kr', 'utf-8')
    @result = {}
  end

  def find
    STORE_LISTS.keys.each do |store|
      # 개별 매장 검색 시작
      store_url = URI.parse(STORE_URI + store)

      search_results = query_book(store_url).css('div.ss_book_box')

      # 매장별 결과는 배열로 리턴 (각 배열의 요소는 해쉬)
      store_result = search_results.map do |book|
        book_info = book.css('div.ss_book_list')[0]
        price_info = book.css('div.ss_book_list')[1]

        title = book_info.css('a.bo_l b').text
        sub_title = book_info.css('span.ss_f_g2').text

        # 특별한 순위를 매기는 경우 li 태그가 하나 더 늘어남 ex) 청소년 100위 2주
        if book_info.css('span.ss_ht2').empty?
          author_list = book_info.css('li')[1].text.split(' | ')
        else
          author_list = book_info.css('li')[2].text.split(' | ')
        end

        author = author_list[0].strip
        publisher = author_list[1].strip
        pub_date = author_list[2].strip

        price = price_info.css('span.ss_p2 b')[0].text
        stock = price_info.css('span.ss_p4 b').text

        {
          title: title,
          sub_title: sub_title,
          author: author,
          publisher: publisher,
          pub_date: pub_date,
          price: price,
          stock: stock
        }
      end

      @result[STORE_LISTS[store]] = store_result
    end
    @result
  end

  private

  def query_book(store_url)
    agent = Mechanize.new

    store_index = agent.get(store_url)
    store_form = store_index.form('QuickSearch')
    store_form['SearchWord'] = @book

    query_result = agent.submit(store_form)
    query_result.encoding = 'EUC-KR'

    query_result
  end
end
