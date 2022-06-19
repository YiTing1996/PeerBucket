//
//  ExploreDataModal.swift
//  PeerBucket
//
//  Created by 陳憶婷 on 2022/6/15.
//

import Foundation
import UIKit

struct ExploreBucket {
    
    let images: [UIImage?]
    let title: String
    let rating: String
    let description: String
    let link: String
}

let exploreList = [exploreMovie, exploreTravel, exploreGift]

let exploreMovie = [
    ExploreBucket(images: [
                    UIImage(named: "movie_her"),
                    UIImage(named: "movie_her1"),
                    UIImage(named: "movie_her2")],
                  title: "Her 雲端情人",
                  rating: "IMDB 8.0",
                  description:
                  """
                  ★ 奧斯卡:最佳影片、原著劇本、藝術指導、電影配樂、原創歌曲等5項大獎提名！\n★ 金球獎:最佳音樂或喜劇類影片、最佳劇本、最佳男主角,三項大獎提名！
                  ★ 金球獎:最佳劇本!!
                  《雲端情人》的背景設定在近未來的洛衫磯，故事以西奧多托姆利（喬昆菲尼克斯飾）為中心，他是個心思細膩又感情豐富的男人，工作是為別人代寫私密感人的信件。
                  某日他買到一套全新研發的智慧軟體，灌進他的電腦數位裝置中。使用後他發現，這套作業系統的功能，著實令他出乎意料地滿意！
                  但更出乎他意料的是，西奧與這套智慧軟體之間，竟然又發展出一種曖昧關係。很快地，他發現他已經愛上了軟體中的「她」了
                  於是，透過這段交雜著未來科幻和傳統浪漫的不尋常愛情，我們看到讓人與人之間孤立起來的冰冷科技，如何再度讓我們溫暖地連接起來。
                  
                  奧斯卡獎提名導演史派克瓊斯以獨特觀點，譜出一則原創的愛情故事，探索現代世界中親密關係的造化和危機。
                  
                  這部電影由史派克瓊斯自編自導，卡司陣容包括奧斯卡獎提名的三大男女演員喬昆菲尼克斯（《世紀教主》、《為你鍾情》、《神鬼戰士》）
                  、艾美亞當斯（《世紀教主》、《超人：鋼鐵英雄》）及魯妮瑪拉（《千禧三部曲I：龍紋身的女孩》），還有奧莉薇亞懷爾德（《決戰終點線》）及史嘉蕾喬韓森（《復仇者聯盟》）。
                  製片是梅根艾利森、史派克瓊斯和文生蘭迪，監製是丹尼爾魯比、娜塔莉法利和雀西巴納德。
                  """,
                  link: "https://movies.yahoo.com.tw/movieinfo_main.html/id=5039"),
    ExploreBucket(images: [
                    UIImage(named: "movie_bigSick"),
                    UIImage(named: "movie_bigSick1"),
                    UIImage(named: "movie_bigSick2")],
                  title: "The Big Sick 愛情昏迷中",
                  rating: "IMDB 7.8",
                  description:
                  """
                  ★ 真實故事改編 男主角本人親身經歷
                  ★ 爛番茄指數高達98% 口碑爆棚
                  ★ “突破愛情戲劇陳腔濫調” – 紐約時報
                  ★《伴娘我最大》《姊姊愛最大》製片再次出擊
                  
                  來自巴基斯坦傳統家庭的庫梅爾（庫梅爾南賈尼 飾）是一名紐約脫口秀喜劇演員，每天都在想梗逗樂觀眾的他，邂逅了活潑爛漫的艾蜜莉（柔依卡珊 飾），從沒想過會一拍即合的兩人，開始了甜蜜的交往關係，直到艾蜜莉發現仍庫梅爾一直跟巴基斯坦的女性見面，
                  持續接受母親安排的相親，這段關係因而開始產生了裂痕，決心分手後的艾蜜莉突然陷入了昏迷的意外，庫梅爾該如何追回艾蜜莉並且安撫家中保守的父母，一場又哭又笑的戀愛大作戰即將展開！
                  """,
                  link: "https://movies.yahoo.com.tw/movieinfo_main/%E6%84%9B%E6%83%85%E6%98%8F%E8%BF%B7%E4%B8%AD-the-big-sick-7043"),
    ExploreBucket(images: [
                    UIImage(named: "movie_theLobster"),
                    UIImage(named: "movie_theLobster1"),
                    UIImage(named: "movie_theLobster2")],
                  title: "The Lobster 單身動物園",
                  rating: "IMDB 7.1",
                  description:
                  """
                  ★ 鬼才導演尤格藍西莫以《單身動物園》奪坎城影展評審團獎 !
                  
                  未來世界，單身有罪。不配對就變動物吧！
                  《單身動物園》（The Lobster）描述柯林法洛（Colin Farrell）飾演的單身男子大衛，與一群孤男寡女被關進豪華飯店，
                  他們必須在45天內找到另一半，配對失敗的人則會變成動物，他無奈下選擇變成龍蝦，
                  因為龍蝦不僅長壽、即使老了性能力還不會退化…。為了繼續當人，木訥的大衛使出渾身解數把妹，卻處處碰壁，
                  萬念俱灰的他只好逃到森林中，在這裡，他遇到了跟自己一樣的失敗者，卻也讓他遇到了真愛…。
                  """,
                  link: "https://movies.yahoo.com.tw/movieinfo_main/%E5%96%AE%E8%BA%AB%E5%8B%95%E7%89%A9%E5%9C%92-the-lobster-6145"),
    ExploreBucket(images: [
                    UIImage(named: "movie_loveSimon"),
                    UIImage(named: "movie_loveSimon1"),
                    UIImage(named: "movie_loveSimon2")],
                  title: "Love, Simon 親愛的初戀",
                  rating: "IMDB 8.0",
                  description:
                  """
                  ★《生命中的美好缺憾》製作團隊 年度溫馨愛情力作
                  ★ 改編自暢銷青少年小說《西蒙和他的出櫃日誌》 亞馬遜評價4.5星年度暢銷佳作
                  ★ 青春初戀的酸甜苦澀 融合校園、友情、家庭之年度必看愛情喜劇
                  ★ 愛情不分貴賤 每個人都值得擁有 跳脫同志電影嚴肅沉重框架必為經典
                  
                  每個人都值得擁有一個偉大的愛情故事。但是對一個17歲的高中生「賽門」來說這一切卻是件超複雜的事：第一、沒有人知道他是同性戀；第二、他也搞不清楚自己愛上跟他一樣有同樣困擾的不具名網友到底是何方神聖？？？
                  為了解決這兩個大麻煩，賽門展開一段爆笑又嚇人的解答過程，但他沒料到的是，最後得到的答案卻從此改變了自己的人生。整部片充滿歡笑、清新、感人，又有初戀般的甜蜜滋味，絕對將成為經典好片。
                  """,
                  link: "https://movies.yahoo.com.tw/movieinfo_main/%E8%A6%AA%E6%84%9B%E7%9A%84%E5%88%9D%E6%88%80-love-simon-7755"),
    ExploreBucket(images: [
                    UIImage(named: "movie_carol"),
                    UIImage(named: "movie_carol1"),
                    UIImage(named: "movie_carol2")],
                  title: "Carol 因為愛你",
                  rating: "IMDB 7.2",
                  description:
                  """
                  ★ 金球獎提名最多項「最佳劇情片」、「最佳導演」、「最佳女主角」(雙入圍)、「最佳配樂」！
                  ★ 強勢問鼎2016年奧斯卡、全球媒體一致滿分盛讚，口碑爆棚！
                  ★ 榮獲坎城影展最佳女主角、酷兒金棕櫚獎！
                  ★ 獲美國電影獨立精神獎「最佳影片」、「最佳導演」、「最佳女主角」(雙入圍)、「最佳劇本」、「最佳攝影」六項提名！
                  ★ 美國演員工會獎「最佳女主角」、「最佳女配角」提名！
                  ★ 獲美國國家影評人協會「最佳導演」、「最佳攝影」大獎！
                  ★ 獲紐約影評人協會「最佳影片」、「最佳導演」、「最佳劇本」、「最佳攝影」四項大獎肯定！
                  ★ 英國倫敦影評人協會7項入圍：「最佳影片」、「最佳導演」、「最佳女主角」(雙入圍)、「最佳劇本」、「最佳攝影」、「最佳電影音樂」！
                  ★ 美國知名網站Rotten Tomatoes 97分極高評價！
                  ★ 奧斯卡影后凱特布蘭琪演技顛峰之作！
                  ★ 魯妮瑪拉繼《龍紋身的女孩》後挑戰高難度角色，勇奪坎城影后殊榮！
                  
                  為了愛，你願意付出多少代價？
                  
                  20幾歲的特芮絲柏李維（魯妮瑪拉飾）熱愛攝影，卻在曼哈頓某間百貨公司當店員，理想與現實的巨大差距讓她充滿痛苦，在這時邂逅了卡蘿（凱特布蘭琪飾），
                  卡蘿是上流社會的貴婦，成熟又充滿魅力，與即將離婚的富有丈夫育有一女，正為了監護權而焦頭爛額。
                  兩人年齡和背景天差地別卻一見鍾情，頻繁的往來讓感情逐漸升溫，一場公路旅行，將感情與慾望燃燒到最高點…
                  
                  卡蘿的丈夫（凱爾錢德勒飾）為了爭取監護權而雇用私家偵探，發現卡蘿與特芮絲以及她最好的朋友艾比（莎拉寶森飾）的親密關係，並以此作為證據質疑她為人母的資格。
                  好不容易擁有愛情和自由的卡蘿，因為女同性戀者的身分，在爭奪監護權的風暴中受到攻擊，而特芮絲也思考這段感情該何去何從……
                  """,
                  link: "https://movies.yahoo.com.tw/movieinfo_main/%E5%9B%A0%E7%82%BA%E6%84%9B%E4%BD%A0-font-classhighlightcarolfont-6094”")
]

let exploreTravel = [
    ExploreBucket(images: [
                    UIImage(named: "Travel_Kenting"),
                    UIImage(named: "Travel_Kenting1")],
                  title: "Kenting, Taiwan",
                  rating: "kkday 4.7",
                  description:
                  """
                  屏東恆春｜鹿境梅花鹿生態園區門票｜墾丁小奈良
                  * 導覽員詳盡的解說，帶你深入認識梅花鹿生態
                  * 近距離接觸園區梅花鹿，享受餵食、拍照的樂趣
                  * 2021年還有新朋友超萌水豚君閃亮登場
                  * 即訂即用各式套票享線上優惠價格，不必排隊購票輕鬆入園好方便
                  * 在 KKday 購買門票加贈梅花鹿復育講座、商品優惠券
                  """,
                  link: "https://www.kkday.com/zh-tw/product/2125"),
    
    ExploreBucket(images: [
                    UIImage(named: "Travel_Hsinchu"),
                    UIImage(named: "Travel_Hsinchu1")],
                  title: "Hsinchu, Taiwan",
                  rating: "kkday 4.7",
                  description:
                  """
                  新竹兩天一夜｜司馬庫斯神木群健行＆鎮西堡教堂＆秘境瀑布｜新竹出發
                  * 探訪具有「上帝的部落」美名的司馬庫斯，深度體驗泰雅風情
                  * 健行於司馬庫斯神木群，一睹整片千年紅檜巨木群的壯觀而神聖的森林風貌，享受大自然的洗禮
                  * 來到人間仙境般的部落，欣賞其自然生態、古老建築及歷史背景
                  """,
                  link: "https://www.kkday.com/zh-tw/product/105531"),
    
    ExploreBucket(images: [
                    UIImage(named: "Travel_Nantou"),
                    UIImage(named: "Travel_Nantou1")],
                  title: "Nantou, Taiwan",
                  rating: "kkday 5.0",
                  description:
                  """
                  南投露營｜峇嵐杉丘・一泊三食野奢露營體驗・2022全新開幕
                  * 2022年6月開幕！鄰近日月潭國家風景區，山林無邊無際，綠意蔓開一片秘境
                  * 絕美星空帳及馬車帳皆有獨立衛浴帳、獨立烤肉爐
                  * 設有三大主題打卡區：三位大自然守護神守護著峇嵐杉丘，在各自的地界佈置了很多有趣的考驗，用特別的方式歡迎大家
                  """,
                  link: "https://www.kkday.com/zh-tw/product/128731"),
    
    ExploreBucket(images: [
                    UIImage(named: "Travel_Penghu"),
                    UIImage(named: "Travel_Penghu1")],
                  title: "Penghu, Taiwan",
                  rating: "kkday 4.5",
                  description:
                  """
                  【2022澎湖花火節】限時85 折｜澎湖｜海上花火船｜遊船海上・島上賞煙火秀
                  2022 年澎湖縣政府將再攜手國人熟悉品牌「LINE FRIENDS」，共同為花火 20 年打造盛大慶典，總共 24 場次的花火活動，延續往年備受歡迎的無人機科技燈光秀以及搭配煙火演出外，現場將以科技燈光裝置創造驚喜，提升無人機數量來增添煙火的多樣性！
                  本行程專為不想出海等待許久，亦不想提早至岸邊佔位的旅客，旅客只需在接近施放煙火的時刻，搭乘快艇直達最佳觀賞地點，即可放鬆享受浪漫的煙火，感受以不同視野欣賞澎湖限定國際海上花火秀的難得體驗 !
                  """,
                  link: "https://www.kkday.com/zh-tw/product/21721"),
    
    ExploreBucket(images: [
                    UIImage(named: "Travel_Lanyu"),
                    UIImage(named: "Travel_Lanyu1")],
                  title: "Lanyu, Taiwan",
                  rating: "kkday 4.9",
                  description:
                  """
                  2022離島水上推薦｜台東蘭嶼SUP 立式單槳體驗
                  * 由專業教練帶領教學， SUP 輕鬆上手
                  * 清澈湛藍的海水，站在板上也能一窺海洋美景
                  * 使用 GoPro 7，幫你捕捉美好時刻
                  * 限時優惠｜ 台東富岡漁港・墾丁後壁湖往返蘭嶼交通｜蘭嶼船票&機車套票
                  """,
                  link: "https://www.kkday.com/zh-tw/product/22844")
]

let exploreGift = [
    ExploreBucket(images: [
                    UIImage(named: "Gift_Camera"),
                    UIImage(named: "Gift_Camera1")],
                  title: "收藏回憶",
                  rating: "Pinkoi 5.0",
                  description:
                  """
                  【Kodak 柯達】Funsaver 一次性即可拍 底片相機 27張 ISO800
                  內含135mm彩色底片27張，感光度ISO 800，機身設有閃光燈，可補光1.2-3.5米的範圍。拆封即可使用拍攝、操作簡便。
                  
                  底片規格：135mm彩色膠捲(27張)
                  感光度：ISO 800
                  閃燈範圍：約1.2~3.5米
                  """,
                  link: "https://www.pinkoi.com/product/yP7m63KK"),
    
    ExploreBucket(images: [
                    UIImage(named: "Gift_Watch"),
                    UIImage(named: "Gift_Watch1"),
                    UIImage(named: "Gift_Watch2")],
                  title: "隨身攜帶",
                  rating: "Pinkoi 4.9",
                  description:
                  """
                  THE ALL NEW EO-3 DIVER 全環境機械腕錶 SILVER PACKAGE 銀
                  
                  所有腕錶皆生產於無塵空間。
                  網狀防滑旋入式錶冠，兩側皆加入錶冠保護。
                  三點鐘方向顯示日期。
                  潛水旋轉錶圈刻度為 CNC 雕刻製作。
                  
                  商品規格：
                  款式：SILVER PACKAGE 銀色款
                  尺寸：錶面 43.5mm（不含錶冠），厚度 12.8mm
                  重量：135g
                  材質：以顯微技術打磨而成的不鏽鋼髮絲紋錶殼 / 絲絨金屬霧面錶盤 / 耐刮與防眩藍寶石玻璃鏡面 / 錶盤指針皆有螢光塗料
                  機芯：日本 SEIKO（精工）自動上鍊機械機芯
                  防水等級：200 公尺防水（接觸海水後務必擦乾，以保持外觀最佳狀態）
                  內容：銀色全環境機械腕錶身一個、軍綠尼龍錶帶，原廠錶盒。
                  """,
                  link: "https://www.pinkoi.com/product/7whW9EPS"),
    
    ExploreBucket(images: [
                    UIImage(named: "Gift_Lamp"),
                    UIImage(named: "Gift_Lamp1"),
                    UIImage(named: "Gift_Lamp2")],
                  title: "療癒身心",
                  rating: "Pinkoi 5.0",
                  description:
                  """
                  北歐大理石融蠟燈 香氛蠟燭 微光冰河/午後暖陽 -HyggeVibe海格萊
                  ❖微光冰河 Dawn of Glacier
                  ➤前味：綠植香、薰衣草、白松香、佛手柑
                  ➤中味：玫瑰、鈴蘭、茉莉
                  ➤後味：雪松、木質香
                  
                  ❖午後暖陽 After Sunshine
                  ➤前味：岩蘭草、鳶尾花
                  ➤中味：葡萄柚
                  ➤後味：檸檬、茉莉
                  
                  ‖生活忙碌，還是需要一點儀式感
                  把將就的日子，過成講究的生活
                  
                  ‖生活有了儀式感，人生才變得豐富多彩
                  海格萊邀您一起感受來自北歐的異國風情
                  創造豐富多元的生活儀式感❤
                  
                  「Hygge Vibe , Hygge life 」 舒適氣氛，舒適生活
                  """,
                  link: "https://www.pinkoi.com/product/WtNkQ658?category=5&ref_itemlist=YC74fs5p"),
    
    ExploreBucket(images: [
                    UIImage(named: "Gift_Keyboard"),
                    UIImage(named: "Gift_Keyboard1"),
                    UIImage(named: "Gift_Keyboard2")],
                  title: "實用推薦",
                  rating: "Pinkoi 4.9",
                  description:
                  """
                  無線藍牙 紅軸 Mac iPad機械鍵盤 三模熱插拔遊戲靜音NuPhy Air75
                  NuPhy Air75 是一款創新的 75% 超薄無線機械鍵盤。 憑借全球最薄的 PBT 球形鍵帽、低延遲 2.4G 無線連接和熱插拔功能，Air75 旨在成為纖薄機械鍵盤的新標准。
                  
                  Air75 的 75% 緊湊佈局兼容 Mac 和 Windows。 您最多可以連接 4 台具有低延遲 2.4G 和藍牙 5.0 的設備，以最好地支持您的所有多任務處理需求。
                  """,
                  link: "https://www.pinkoi.com/product/MydvQFEG"),
    
    ExploreBucket(images: [
                UIImage(named: "Gift_Bottle"),
                UIImage(named: "Gift_Bottle1"),
                UIImage(named: "Gift_Bottle2")],
                  title: "夏季必備",
                  rating: "Pinkoi 4.0",
                  description:
                  """
                  【時尚風自動扣瓶氣泡水機 Spirit-白】
                  -限時買就送 水滴型專用水瓶1L 3入(夏日果宴)。贈完以等價商品代替
                  -全球家用氣泡水機第一品牌
                  -耀眼光澤、摩登簡約造型
                  -自動扣瓶裝置，不用再手動旋轉鎖瓶子了
                  -隱藏功能式機頂打氣方塊，全機設計更精簡
                  """,
                  link: "https://www.pinkoi.com/product/pUStgfq8")
]

let challengeList = ["challenge_hiking", "challenge_diving", "challenge_summer"]
let challengeMainImage = ["challenge_hiking_1", "challenge_diving_1", "challenge_summer_1"]
