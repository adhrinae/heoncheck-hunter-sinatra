class BookSearch
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

  def initialize(book_title)
    @book_title = book_title.encode('euc-kr', 'utf-8')
    @agent = Mechanize.new
    @result = {}
  end

  def search
    STORE_LISTS.each do |store_code, store_name|
      # 개별 매장 검색 시작
      search_results = get_books(store_code)
      @result[store_name] = serialize_info(search_results)
    end

    @result
  end

  private

  def query(store_url)
    store_index = @agent.get(store_url)
    store_form = store_index.form('QuickSearch')
    store_form['SearchWord'] = @book_title

    query_result = @agent.submit(store_form)
    query_result.encoding = 'EUC-KR'

    query_result
  end

  def get_books(store_code)
    store_url = URI.parse(STORE_URI + store_code)
    query(store_url).css('div.ss_book_box')
  end

  def serialize_info(search_results)
    # 검색 결과가 있다면 검색 시작, 아니면 빈 배열 그대로 리턴
    return search_results if search_results.empty?

    # 매장별 결과는 배열로 리턴 (각 배열의 요소는 해쉬)
    search_results.map do |book|
      book_info, price_info = book.css('div.ss_book_list')[0..1]

      title = book_info.css('a.bo_l b').text
      sub_title = book_info.css('span.ss_f_g2').text

      author_list = book_info.css('ul > li')[-1].text.split(' | ')

      author, publisher, pub_date = author_list[0..2]

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
  end
end
