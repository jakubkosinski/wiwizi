require 'set'
require 'stemmer'

class Index
  attr_accessor :index, :positions, :frequencies
  COMMON_WORDS =
    ['a','able','about','above','abroad','according','accordingly','across','actually','adj','after',
    'afterwards','again','against','ago','ahead','aint','all','allow','allows','almost','alone',
    'along','alongside','already','also','although','always','am','amid','amidst','among',
    'amongst','an','and','another','any','anybody','anyhow','anyone','anything','anyway',
    'anyways','anywhere','apart','appear','appreciate','appropriate','are','arent','around',
    'as','as','aside','ask','asking','associated','at','available','away','awfully','b',
    'back','backward','backwards','be','became','because','become','becomes','becoming','been',
    'before','beforehand','begin','behind','being','believe','below','beside','besides','best',
    'better','between','beyond','both','brief','but','by','c','came','can','cannot','cant','cant',
    'caption','cause','causes','certain','certainly','changes','clearly','cmon','co','co.','com',
    'come','comes','concerning','consequently','consider','considering','contain','containing',
    'contains','corresponding','could','couldnt','course','cs','currently','d','dare','darent',
    'definitely','described','despite','did','didnt','different','directly','do','does','doesnt','doing',
    'done','dont','down','downwards','during','e','each','edu','eg','eight','eighty','either','else',
    'elsewhere','end','ending','enough','entirely','especially','et','etc','even','ever','evermore',
    'every','everybody','everyone','everything','everywhere','ex','exactly','example','except','f',
    'fairly','far','farther','few','fewer','fifth','first','five','followed','following','follows',
    'for','forever','former','formerly','forth','forward','found','four','from','further','furthermore',
    'g','get','gets','getting','given','gives','go','goes','going','gone','got','gotten','greetings',
    'h','had','hadnt','half','happens','hardly','has','hasnt','have','havent','having','he','hed','hell',
    'hello','help','hence','her','here','hereafter','hereby','herein','heres','hereupon','hers','herself',
    'hes','hi','him','himself','his','hither','hopefully','how','howbeit','however','hundred','i','id',
    'ie','if','ignored','ill','im','immediate','in','inasmuch','inc','inc.','indeed','indicate','indicated',
    'indicates','inner','inside','insofar','instead','into','inward','is','isnt','it','itd','itll','its',
    'its','itself','ive','j','just','k','keep','keeps','kept','know','known','knows','l','last','lately',
    'later','latter','latterly','least','less','lest','let','lets','like','liked','likely','likewise','little',
    'look','looking','looks','low','lower','ltd','m','made','mainly','make','makes','many','may','maybe',
    'maynt','me','mean','meantime','meanwhile','merely','might','mightnt','mine','minus','miss','more','moreover',
    'most','mostly','mr','mrs','much','must','mustnt','my','myself','n','name','namely','nd','near',
    'nearly','necessary','need','neednt','needs','neither','never','neverf','neverless','nevertheless','new',
    'next','nine','ninety','no','nobody','non','none','nonetheless','noone','no-one','nor','normally','not','nothing','notwithstanding','novel','now','nowhere','o','obviously','of','off',
    'often','oh','ok','okay','old','on','once','one','ones','ones','only','onto','opposite','or','other','others',
    'otherwise','ought','oughtnt','our','ours','ourselves','out','outside','over','overall','own','p','particular',
    'particularly','past','per','perhaps','placed','please','plus','possible','presumably','probably','provided',
    'provides','q','que','quite','qv','r','rather','rd','re','really','reasonably','recent','recently','regarding',
    'regardless','regards','relatively','respectively','right','round','s','said','same','saw','say','saying','says',
    'second','secondly','see','seeing','seem','seemed','seeming','seems','seen','self','selves','sensible','sent',
    'serious','seriously','seven','several','shall','shant','she','shed','shell','shes','should','shouldnt','since',
    'six','so','some','somebody','someday','somehow','someone','something','sometime','sometimes','somewhat','
    somewhere','soon','sorry','specified','specify','specifying','still','sub','such','sup','sure','t','take','taken',
    'taking','tell','tends','th','than','thank','thanks','thanx','that','thatll','thats','thats','thatve','the',
    'their','theirs','them','themselves','then','thence','there','thereafter','thereby','thered','therefore','therein',
    'therell','therere','theres','theres','thereupon','thereve','these','they','theyd','theyll','theyre','theyve',
    'thing','things','think','third','thirty','this','thorough','thoroughly','those','though','three','through',
    'throughout','thru','thus','till','to','together','too','took','toward','towards','tried','tries','truly','try',
    'trying','ts','twice','two','u','un','under','underneath','undoing','unfortunately','unless','unlike','unlikely',
    'until','unto','up','upon','upwards','us','use','used','useful','uses','using','usually','v','value','various',
    'versus','very','via','viz','vs','w','want','wants','was','wasnt','way','we','wed','welcome','well','well','went',
    'were','were','werent','weve','what','whatever','whatll','whats','whatve','when','whence','whenever','where',
    'whereafter','whereas','whereby','wherein','wheres','whereupon','wherever','whether','which','whichever','while',
    'whilst','whither','who','whod','whoever','whole','wholl','whom','whomever','whos','whose','why','will','willing',
    'wish','with','within','without','wonder','wont','would','wouldnt','x','y','yes','yet','you','youd','youll','your',
    'youre','yours','yourself','yourselves','youve','z','zero'].to_set

  def initialize(type = :basic, options = {})
    @type = type
    @index = options[:index] || {}
    @positions = options[:positions] || {}
    @frequencies = options[:frequencies] || {}
  end

  def index_document(file_name)
    words = File.read(file_name).gsub(/[^\w\s]/,"").split
    words.each_with_index do |word, index|
      case @type
      when :stemmer
        add_with_stemmer(word, file_name, index)
      else
        add_without_stemmer(word, file_name, index)
      end
    end
  end

  def save_to_file(options = {})
    names = {:index => "index.dat", :frequencies => "frequencies.dat", :positions => "positions.dat"}.merge(options)
    save_index names[:index]
    save_frequencies names[:frequencies]
    #save_positions names[:positions]
  end

  def self.load_index(type = :basic, options = {})
    names = {:index => "index.dat", :frequencies => "frequencies.dat", :positions => "positions.dat"}.merge(options)
    index = Marshal.load(File.read(names[:index]))
    frequencies = Marshal.load(File.read(names[:frequencies]))
    #positions = Marshal.load(File.read(names[:positions]))
    Index.new(type, :index => index, :frequencies => frequencies)
  end

  protected

  def save_index(file)
    File.open(file, "wb"){|f| f << Marshal.dump(@index)}
  end

  def save_positions(file)
    File.open(file, "wb"){|f| f << Marshal.dump(@positions)}
  end

  def save_frequencies(file)
    File.open(file, "wb"){|f| f << Marshal.dump(@frequencies)}
  end

  def add_with_stemmer(word, file_name, index)
    return if COMMON_WORDS.include? word
    stem = word.downcase.stem
    (@index[stem] ||= Set.new) << file_name                   # add file name to stem set
    #(@positions[stem] ||= Hash.new([]))[file_name] << index   # add position of stem in file
    (@frequencies[stem] ||= Hash.new(0))[file_name] += 1      # increment frequency of stem in file
  end

  def add_without_stemmer(word, file_name, index)
    word = word.downcase
    @index[word] ||= Set.new
    @index[word] << file_name
  end
end
