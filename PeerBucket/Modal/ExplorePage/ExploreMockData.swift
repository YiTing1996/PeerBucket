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
                    UIImage(named: "movie_bigSick"),
                    UIImage(named: "movie_bigSick1"),
                    UIImage(named: "movie_bigSick2")],
                  title: "The Big Sick",
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
                  title: "The Lobster",
                  rating: "IMDB 7.1",
                  description:
                  """
                  ★ 鬼才導演尤格藍西莫以《單身動物園》奪坎城影展評審團獎 !
                  
                  未來世界，單身有罪。不配對就變動物吧！
                  《單身動物園》（The Lobster）描述柯林法洛（Colin Farrell）飾演的單身男子大衛，與一群孤男寡女被關進豪華飯店，他們必須在45天內找到另一半，配對失敗的人則會變成動物，
                  他無奈下選擇變成龍蝦，因為龍蝦不僅長壽、即使老了性能力還不會退化…。為了繼續當人，木訥的大衛使出渾身解數把妹，卻處處碰壁，
                  萬念俱灰的他只好逃到森林中，在這裡，他遇到了跟自己一樣的失敗者，卻也讓他遇到了真愛 …。
                  """,
                  link: "https://movies.yahoo.com.tw/movieinfo_main/%E5%96%AE%E8%BA%AB%E5%8B%95%E7%89%A9%E5%9C%92-the-lobster-6145"),
    ExploreBucket(images: [
                    UIImage(named: "movie_loveSimon"),
                    UIImage(named: "movie_loveSimon1"),
                    UIImage(named: "movie_loveSimon2")],
                  title: "Love, Simon",
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
                  title: "Carol",
                  rating: "IMDB 7.2",
                  description:
                  """
                  ★ 強勢問鼎2016年奧斯卡、全球媒體一致滿分盛讚！
                  ★ 榮獲坎城影展最佳女主角、酷兒金棕櫚獎！
                  ★ 獲美國電影獨立精神獎「最佳影片」、「最佳導演」、「最佳女主角」等六項提名！
                  ★ 美國演員工會獎「最佳女主角」、「最佳女配角」提名！
                  
                  為了愛，你願意付出多少代價？
                  
                  20幾歲的特芮絲柏李維（魯妮瑪拉飾）熱愛攝影，卻在曼哈頓某間百貨公司當店員，理想與現實的巨大差距讓她充滿痛苦，在這時邂逅了卡蘿（凱特布蘭琪飾），
                  卡蘿是上流社會的貴婦，成熟又充滿魅力，與即將離婚的富有丈夫育有一女，正為了監護權而焦頭爛額。
                  兩人年齡和背景天差地別卻一見鍾情，頻繁的往來讓感情逐漸升溫，一場公路旅行，將感情與慾望燃燒到最高點…
                  
                  卡蘿的丈夫（凱爾錢德勒飾）為了爭取監護權而雇用私家偵探，發現卡蘿與特芮絲以及她最好的朋友艾比（莎拉寶森飾）的親密關係，並以此作為證據質疑她為人母的資格。
                  好不容易擁有愛情和自由的卡蘿，因為女同性戀者的身分，在爭奪監護權的風暴中受到攻擊，而特芮絲也思考這段感情該何去何從 ……
                  """,
                  link: "https://movies.yahoo.com.tw/movieinfo_main/%E5%9B%A0%E7%82%BA%E6%84%9B%E4%BD%A0-font-classhighlightcarolfont-6094"),
    ExploreBucket(images: [
                    UIImage(named: "movie_her"),
                    UIImage(named: "movie_her1"),
                    UIImage(named: "movie_her2")],
                  title: "Her",
                  rating: "IMDB 8.0",
                  description:
                  """
                  ★ 奧斯卡: 最佳影片、原著劇本、藝術指導、電影配樂、原創歌曲等5項大獎提名！\n★ 金球獎: 最佳音樂或喜劇類影片、最佳劇本、最佳男主角,三項大獎提名！
                  ★ 金球獎: 最佳劇本!!
                  《雲端情人》的背景設定在近未來的洛衫磯，故事以西奧多托姆利（喬昆菲尼克斯飾）為中心，他是個心思細膩又感情豐富的男人，工作是為別人代寫私密感人的信件。
                  某日他買到一套全新研發的智慧軟體，灌進他的電腦數位裝置中。使用後他發現，這套作業系統的功能，著實令他出乎意料地滿意！
                  但更出乎他意料的是，西奧與這套智慧軟體之間，竟然又發展出一種曖昧關係。很快地，他發現他已經愛上了軟體中的「她」了
                  於是，透過這段交雜著未來科幻和傳統浪漫的不尋常愛情，我們看到讓人與人之間孤立起來的冰冷科技，如何再度讓我們溫暖地連接起來。
                  
                  奧斯卡獎提名導演史派克瓊斯以獨特觀點，譜出一則原創的愛情故事，探索現代世界中親密關係的造化和危機。

                  """,
                  link: "https://movies.yahoo.com.tw/movieinfo_main.html/id=5039")
]

let exploreTravel = [
    ExploreBucket(images: [
                    UIImage(named: "Travel_Kenting"),
                    UIImage(named: "Travel_Kenting1")],
                  title: "Kenting, Taiwan",
                  rating: "kkday 4.7",
                  description:
                  """
                  屏東恆春｜鹿境梅花鹿生態園區｜墾丁小奈良
                  ★ 導覽員詳盡的解說，帶你深入認識梅花鹿生態
                  ★ 近距離接觸園區梅花鹿，享受餵食、拍照的樂趣
                  ★ 2021年還有新朋友超萌水豚君閃亮登場

                  """,
                  link: "https://www.kkday.com/zh-tw/product/2125"),
    
    ExploreBucket(images: [
                    UIImage(named: "Travel_Hsinchu"),
                    UIImage(named: "Travel_Hsinchu1")],
                  title: "Hsinchu, Taiwan",
                  rating: "kkday 4.7",
                  description:
                  """
                  新竹司馬庫斯｜神木群健行＆鎮西堡教堂＆秘境瀑布
                  ★ 適合一地體驗多元景觀樣貌
                  ★ 體驗人間仙境部落文化
                  
                  有「上帝的部落」美名的司馬庫斯，位在新竹的尖石鄉，海拔約1500公尺，是最深山的原住民部落，也是全台灣最晚有電力送達的地區，遺世獨立。後也因
                  千年紅檜巨木群壯觀而神聖的森林風貌而出名，據林務局資料，台灣第二名第三名的神木皆位於司馬庫斯神木區。除了神木群外，泰雅部落古老建築及歷史背景，與司立富觀瀑步道等美景，也讓司馬庫斯成為獨一無二人間仙境。
                  
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
                  ★ 適合遠離都市享受兩人寧靜時光
                  ★ 絕美星空帳在星空下浪漫入眠
                  
                  峇嵐杉丘座落於魚池鄉金龍山旁，鄰近日月潭國家風景區，山林無邊無際，綠意蔓開一片秘境，園主希望入住旅客都能感受「杉中」之美好。
                  主打一泊三食野奢露營體驗，以「大自然守護神」為元素設有3大主題區，每間星空帳及馬車帳皆有獨立衛浴帳與獨立烤肉爐，享受營火時光外，
                  早晨更有多元手作體驗活動安排。
                  
                  """,
                  link: "https://www.kkday.com/zh-tw/product/128731"),
    
    ExploreBucket(images: [
                    UIImage(named: "Travel_Chiayi"),
                    UIImage(named: "Travel_Chiayi1")],
                  title: "Mianyue Station",
                  rating: "kkday 5.0",
                  description:
                  """
                  嘉義阿里山 ｜ 眠月線鐵道
                  ★ 適合想要戶外遊走但只有短暫休息日
                  ★ 遠離都市喜愛發掘台灣失落秘境
                  
                  位在阿里山森林遊樂區裡的眠月線，原為1913年開發的塔山線（前段），已有逾百年歷史，因921大地震受損嚴重而停駛，雖然2008年時部分修復完成，隔年卻又碰上八八風災再度受重創，但也因沿途的鐵道、森林、隧道的夢幻美景，有了阿里山失落秘境之稱。
                  路線總長9.2公里，總爬升高度僅有100公尺的落差，是許多登山、健行客趨之若鶩的路線，近期也被封為「 台灣最美的森林鐵路步道 」。對新手來說輕鬆友善，適合一天來回或兩天一夜的放鬆之旅，紮營賞星空，迎接早晨曙光。
                  """,
                  link: "https://www.kkday.com/zh-tw/product/39718"),
    
    ExploreBucket(images: [
                    UIImage(named: "Travel_Lanyu"),
                    UIImage(named: "Travel_Lanyu1")],
                  title: "Lanyu, Taiwan",
                  rating: "kkday 4.9",
                  description:
                  """
                  台東蘭嶼｜SUP 立式單槳體驗
                  ★ 適合SUP水上活動初體驗
                  ★ 由專業教練帶領教學，輕鬆上手
                  ★ 清澈湛藍的海水，站在板上也能一窺海洋美景
                  
                  蘭嶼位在台灣本島東南方的外海上，屬於火山島地形，因此島上以高山地形為主，其他還有丘陵、溪流及曲折的岩岸地形遍布其中，
                  這樣多元的自然景點也讓許多國內外旅客趨之若鶩。但也因高山遍布，所以蘭嶼最熱鬧及主要的景點都集中在沿海地區，
                  其中更可觀賞海洋民族中的達悟族人，仍保留的飛魚祭傳統文化。在台東蘭嶼海域清澈深藍的海上，來體驗不一樣的SUP早晨時光吧！

                  """,
                  link: "https://www.kkday.com/zh-tw/product/22844")
]

let exploreGift = [
    ExploreBucket(images: [
                    UIImage(named: "Gift_Camera"),
                    UIImage(named: "Gift_Camera1")],
                  title: "Kodak Funsaver",
                  rating: "Pinkoi 5.0",
                  description:
                  """
                  【Kodak 柯達】Funsaver
                  一次性即可拍 底片相機 27張 ISO800
                  內含135mm彩色底片27張，感光度ISO 800，機身設有閃光燈，可補光1.2-3.5米的範圍。
                  拆封即可使用拍攝、操作簡便。
                  
                  底片規格：135mm彩色膠捲(27張)
                  感光度：ISO 800
                  閃燈範圍：約1.2~3.5米
                  """,
                  link: "https://www.pinkoi.com/product/yP7m63KK"),
    
    ExploreBucket(images: [
                    UIImage(named: "Gift_Watch"),
                    UIImage(named: "Gift_Watch1"),
                    UIImage(named: "Gift_Watch2")],
                  title: "Sliver Watch",
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
                  title: "Scented Candel",
                  rating: "Pinkoi 5.0",
                  description:
                  """
                  北歐大理石融蠟燈 香氛蠟燭
                  ❖ 微光冰河 Dawn of Glacier
                  ➤ 前味：綠植香、薰衣草、白松香、佛手柑
                  ➤ 中味：玫瑰、鈴蘭、茉莉
                  ➤ 後味：雪松、木質香
                  
                  ❖ 午後暖陽 After Sunshine
                  ➤ 前味：岩蘭草、鳶尾花
                  ➤ 中味：葡萄柚
                  ➤ 後味：檸檬、茉莉
                  
                  ‖ 生活忙碌，還是需要一點儀式感
                  把將就的日子，過成講究的生活
                  
                  ‖ 生活有了儀式感，人生才變得豐富多彩
                  海格萊邀您一起感受來自北歐的異國風情
                  創造豐富多元的生活儀式感❤
                  
                  「Hygge Vibe , Hygge life 」 舒適氣氛，舒適生活
                  """,
                  link: "https://www.pinkoi.com/product/WtNkQ658?category=5&ref_itemlist=YC74fs5p"),
    
    ExploreBucket(images: [
                    UIImage(named: "Gift_Keyboard"),
                    UIImage(named: "Gift_Keyboard1"),
                    UIImage(named: "Gift_Keyboard2")],
                  title: "Bluetooth Keyboard",
                  rating: "Pinkoi 4.9",
                  description:
                  """
                  無線藍牙 紅軸 Mac iPad機械鍵盤
                  三模熱插拔遊戲靜音NuPhy Air75
                  NuPhy Air75 是一款創新的 75% 超薄無線機械鍵盤。
                  憑借全球最薄的 PBT 球形鍵帽、低延遲 2.4G 無線連接和熱插拔功能，Air75 旨在成為纖薄機械鍵盤的新標准。
                  
                  Air75 的 75% 緊湊佈局兼容 Mac 和 Windows。
                  您最多可以連接 4 台具有低延遲 2.4G 和藍牙 5.0 的設備，以最好地支持您的所有多任務處理需求。
                  """,
                  link: "https://www.pinkoi.com/product/MydvQFEG"),
    
    ExploreBucket(images: [
                UIImage(named: "Gift_Bottle"),
                UIImage(named: "Gift_Bottle1"),
                UIImage(named: "Gift_Bottle2")],
                  title: "Sparkling Machine",
                  rating: "Pinkoi 4.0",
                  description:
                  """
                  時尚風自動扣瓶氣泡水機
                  全球家用氣泡水機第一品牌Sodastream，不僅注重生活態度，更相信優質的設計與品質，擅長以簡潔的線條與個性形體呈現，
                  讓您的居家生活更有品質，總是能夠為家居生活帶來與眾不同的感受。
                  自動扣瓶裝置設計，不用再手動旋轉鎖品質，更有隱藏功能式機頂打氣方塊，
                  隨心所欲調整氣泡量，為炎炎夏日果汁、調酒等各式飲品，添加不一樣的風味吧！
                  
                  """,
                  link: "https://www.pinkoi.com/product/pUStgfq8")
]

let challengeList = ["challenge_hiking", "challenge_diving", "challenge_summer"]
let challengeMainImage = ["challenge_hiking_1", "challenge_diving_1", "challenge_summer_1"]

let iconButtonImage: [String] = [
    "icon_bucket_travel", "icon_bucket_movie", "icon_bucket_shopping",
    "icon_bucket_swim", "icon_bucket_mountain", "icon_bucket_guitar",
    "icon_bucket_book", "icon_bucket_favi", "icon_bucket_mountain2",
    "icon_bucket_basketball", "icon_bucket_game", "icon_bucket_cook",
    "icon_bucket_bar", "icon_bucket_diving"
]
