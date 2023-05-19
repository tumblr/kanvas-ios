{
  activesupport = {
    dependencies = ["concurrent-ruby" "i18n" "minitest" "tzinfo"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15m0b1im6i401ab51vzr7f8nk8kys1qa0snnl741y3sir3xd07jp";
      type = "gem";
    };
    version = "7.0.4.3";
  };
  addressable = {
    dependencies = ["public_suffix"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15s8van7r2ad3dq6i03l3z4hqnvxcq75a3h72kxvf9an53sqma20";
      type = "gem";
    };
    version = "2.8.4";
  };
  algoliasearch = {
    dependencies = ["httpclient" "json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ly8zsgvih540xmxr098hsngv61cf119wf28q5hbvi1f7kgwvh96";
      type = "gem";
    };
    version = "1.27.5";
  };
  artifactory = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wify8rhjwr5bw5y6ary61vba290vk766cxw9a9mg05yswmaisls";
      type = "gem";
    };
    version = "3.0.15";
  };
  ast = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04nc8x27hlzlrr5c2gn7mar4vdr0apw5xg22wp6m8dx3wqr04a0y";
      type = "gem";
    };
    version = "2.4.2";
  };
  atomos = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17vq6sjyswr5jfzwdccw748kgph6bdw30bakwnn6p8sl4hpv4hvx";
      type = "gem";
    };
    version = "0.1.3";
  };
  aws-eventstream = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1pyis1nvnbjxk12a43xvgj2gv0mvp4cnkc1gzw0v1018r61399gz";
      type = "gem";
    };
    version = "1.2.0";
  };
  aws-partitions = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1nf52qxqb1bk3l82qk5jar6y5isyskvmni1k9199ibn8a6y02bkk";
      type = "gem";
    };
    version = "1.763.0";
  };
  aws-sdk-core = {
    dependencies = ["aws-eventstream" "aws-partitions" "aws-sigv4" "jmespath"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "06scfn1qjfqvgr05ddrcbihlnfi7bffk8r0m5z536w4mm1s3gh6x";
      type = "gem";
    };
    version = "3.172.0";
  };
  aws-sdk-kms = {
    dependencies = ["aws-sdk-core" "aws-sigv4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bcm0c9f7xy5qj5f0z3gddqslhb2vzrj9smc39pgqyq4jmn5kpj0";
      type = "gem";
    };
    version = "1.64.0";
  };
  aws-sdk-s3 = {
    dependencies = ["aws-sdk-core" "aws-sdk-kms" "aws-sigv4"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "01cryf8kfkmlsxb327szcwcagsp7lss5gmk6zxlgap65lv8bc7rx";
      type = "gem";
    };
    version = "1.122.0";
  };
  aws-sigv4 = {
    dependencies = ["aws-eventstream"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "11hkna2av47bl0yprgp8k4ya70rc3m2ib5w10fn0piplgkkmhz7m";
      type = "gem";
    };
    version = "1.5.2";
  };
  babosa = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16dwqn33kmxkqkv51cwiikdkbrdjfsymlnc0rgbjwilmym8a9phq";
      type = "gem";
    };
    version = "1.0.4";
  };
  CFPropertyList = {
    dependencies = ["rexml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1a36zn77yyibqsfpka0i8vgf3yv98ic2b9wwlbc29566y8wpa2bq";
      type = "gem";
    };
    version = "3.0.6";
  };
  claide = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bpqhc0kqjp1bh9b7ffc395l9gfls0337rrhmab4v46ykl45qg3d";
      type = "gem";
    };
    version = "1.1.0";
  };
  cocoapods = {
    dependencies = ["addressable" "claide" "cocoapods-core" "cocoapods-deintegrate" "cocoapods-downloader" "cocoapods-plugins" "cocoapods-search" "cocoapods-trunk" "cocoapods-try" "colored2" "escape" "fourflusher" "gh_inspector" "molinillo" "nap" "ruby-macho" "xcodeproj"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0c25gpi6vrv4fvhwfqscjq5pqqg3g3s3vjm6z8xmgbi9bl9m7ws8";
      type = "gem";
    };
    version = "1.12.1";
  };
  cocoapods-core = {
    dependencies = ["activesupport" "addressable" "algoliasearch" "concurrent-ruby" "fuzzy_match" "nap" "netrc" "public_suffix" "typhoeus"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "03hz6i56603j3zlxy9is74bgs88isrnj9y7xc6wakr4c0m238hv9";
      type = "gem";
    };
    version = "1.12.1";
  };
  cocoapods-deintegrate = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18pnng0lv5z6kpp8hnki0agdxx979iq6hxkfkglsyqzmir22lz2i";
      type = "gem";
    };
    version = "1.0.5";
  };
  cocoapods-downloader = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jgipkiah3z6qb9ax6qac3b2m1idavd5adc319k5rjsfddpfgszh";
      type = "gem";
    };
    version = "1.6.3";
  };
  cocoapods-plugins = {
    dependencies = ["nap"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16na82sfyc8801qs1n22nwq486s4j7yj6rj7fcp8cbxmj371fpbj";
      type = "gem";
    };
    version = "1.0.0";
  };
  cocoapods-search = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12amy0nknv09bvzix8bkmcjn996c50c4ms20v2dl7v8rcw73n4qv";
      type = "gem";
    };
    version = "1.0.1";
  };
  cocoapods-trunk = {
    dependencies = ["nap" "netrc"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cgdx7z9psxxrsa13fk7qc9i6jskrwcafhrdz94avzia2y6dlnsz";
      type = "gem";
    };
    version = "1.6.0";
  };
  cocoapods-try = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1znyp625rql37ivb5rk9fk9564cmax8icxfr041ysivpdrn98nql";
      type = "gem";
    };
    version = "1.2.0";
  };
  colored = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0b0x5jmsyi0z69bm6sij1k89z7h0laag3cb4mdn7zkl9qmxb90lx";
      type = "gem";
    };
    version = "1.2";
  };
  colored2 = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jlbqa9q4mvrm73aw9mxh23ygzbjiqwisl32d8szfb5fxvbjng5i";
      type = "gem";
    };
    version = "3.1.2";
  };
  commander = {
    dependencies = ["highline"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n8k547hqq9hvbyqbx2qi08g0bky20bbjca1df8cqq5frhzxq7bx";
      type = "gem";
    };
    version = "4.6.0";
  };
  concurrent-ruby = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0krcwb6mn0iklajwngwsg850nk8k9b35dhmc2qkbdqvmifdi2y9q";
      type = "gem";
    };
    version = "1.2.2";
  };
  declarative = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yczgnqrbls7shrg63y88g7wand2yp9h6sf56c9bdcksn5nds8c0";
      type = "gem";
    };
    version = "0.0.20";
  };
  digest-crc = {
    dependencies = ["rake"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1czaak53w8n13y1fr0q23gp0fhklvxjac5n562qj3xk6sh5ad0x2";
      type = "gem";
    };
    version = "0.6.4";
  };
  domain_name = {
    dependencies = ["unf"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lcqjsmixjp52bnlgzh4lg9ppsk52x9hpwdjd53k8jnbah2602h0";
      type = "gem";
    };
    version = "0.5.20190701";
  };
  dotenv = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1n0pi8x8ql5h1mijvm8lgn6bhq4xjb5a500p5r1krq4s6j9lg565";
      type = "gem";
    };
    version = "2.8.1";
  };
  emoji_regex = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jsnrkfy345v66jlm2xrz8znivfnamg3mfzkddn414bndf2vxn7c";
      type = "gem";
    };
    version = "3.2.3";
  };
  escape = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0sa1xkfc9jvkwyw1jbz3jhkq0ms1zrvswi6mmfiwcisg5fp497z4";
      type = "gem";
    };
    version = "0.0.4";
  };
  ethon = {
    dependencies = ["ffi"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17ix0mijpsy3y0c6ywrk5ibarmvqzjsirjyprpsy3hwax8fdm85v";
      type = "gem";
    };
    version = "0.16.0";
  };
  excon = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j826kfvzn7nc5pv950n270r0sx1702k988ad11cdlav3dcxxw09";
      type = "gem";
    };
    version = "0.99.0";
  };
  faraday = {
    dependencies = ["faraday-em_http" "faraday-em_synchrony" "faraday-excon" "faraday-httpclient" "faraday-multipart" "faraday-net_http" "faraday-net_http_persistent" "faraday-patron" "faraday-rack" "faraday-retry" "ruby2_keywords"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1c760q0ks4vj4wmaa7nh1dgvgqiwaw0mjr7v8cymy7i3ffgjxx90";
      type = "gem";
    };
    version = "1.10.3";
  };
  faraday-cookie_jar = {
    dependencies = ["faraday" "http-cookie"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "00hligx26w9wdnpgsrf0qdnqld4rdccy8ym6027h5m735mpvxjzk";
      type = "gem";
    };
    version = "0.0.7";
  };
  faraday-em_http = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "12cnqpbak4vhikrh2cdn94assh3yxza8rq2p9w2j34bqg5q4qgbs";
      type = "gem";
    };
    version = "1.0.0";
  };
  faraday-em_synchrony = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vgrbhkp83sngv6k4mii9f2s9v5lmp693hylfxp2ssfc60fas3a6";
      type = "gem";
    };
    version = "1.0.0";
  };
  faraday-excon = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0h09wkb0k0bhm6dqsd47ac601qiaah8qdzjh8gvxfd376x1chmdh";
      type = "gem";
    };
    version = "1.1.0";
  };
  faraday-httpclient = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0fyk0jd3ks7fdn8nv3spnwjpzx2lmxmg2gh4inz3by1zjzqg33sc";
      type = "gem";
    };
    version = "1.0.1";
  };
  faraday-multipart = {
    dependencies = ["multipart-post"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09871c4hd7s5ws1wl4gs7js1k2wlby6v947m2bbzg43pnld044lh";
      type = "gem";
    };
    version = "1.0.4";
  };
  faraday-net_http = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1fi8sda5hc54v1w3mqfl5yz09nhx35kglyx72w7b8xxvdr0cwi9j";
      type = "gem";
    };
    version = "1.0.1";
  };
  faraday-net_http_persistent = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0dc36ih95qw3rlccffcb0vgxjhmipsvxhn6cw71l7ffs0f7vq30b";
      type = "gem";
    };
    version = "1.2.0";
  };
  faraday-patron = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19wgsgfq0xkski1g7m96snv39la3zxz6x7nbdgiwhg5v82rxfb6w";
      type = "gem";
    };
    version = "1.0.0";
  };
  faraday-rack = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1h184g4vqql5jv9s9im6igy00jp6mrah2h14py6mpf9bkabfqq7g";
      type = "gem";
    };
    version = "1.0.0";
  };
  faraday-retry = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "153i967yrwnswqgvnnajgwp981k9p50ys1h80yz3q94rygs59ldd";
      type = "gem";
    };
    version = "1.0.3";
  };
  faraday_middleware = {
    dependencies = ["faraday"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1bw8mfh4yin2xk7138rg3fhb2p5g2dlmdma88k82psah9mbmvlfy";
      type = "gem";
    };
    version = "1.2.0";
  };
  fastimage = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nnggg20za5vamdpkgrxxa32z33d8hf0g2bciswkhqnc6amb3yjr";
      type = "gem";
    };
    version = "2.2.6";
  };
  fastlane = {
    dependencies = ["CFPropertyList" "addressable" "artifactory" "aws-sdk-s3" "babosa" "colored" "commander" "dotenv" "emoji_regex" "excon" "faraday" "faraday-cookie_jar" "faraday_middleware" "fastimage" "gh_inspector" "google-apis-androidpublisher_v3" "google-apis-playcustomapp_v1" "google-cloud-storage" "highline" "json" "jwt" "mini_magick" "multipart-post" "naturally" "optparse" "plist" "rubyzip" "security" "simctl" "terminal-notifier" "terminal-table" "tty-screen" "tty-spinner" "word_wrap" "xcodeproj" "xcpretty" "xcpretty-travis-formatter"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15sa3v3aaslympg9nmadmpxpbzykdiybzxn3navc7mf0iscb3q7s";
      type = "gem";
    };
    version = "2.212.2";
  };
  ffi = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1862ydmclzy1a0cjbvm8dz7847d9rch495ib0zb64y84d3xd4bkg";
      type = "gem";
    };
    version = "1.15.5";
  };
  fourflusher = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1afabh3g3gwj0ad53fs62waks815xcckf7pkci76l6vrghffcg8v";
      type = "gem";
    };
    version = "2.3.1";
  };
  fuzzy_match = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19gw1ifsgfrv7xdi6n61658vffgm1867f4xdqfswb2b5h6alzpmm";
      type = "gem";
    };
    version = "2.0.4";
  };
  gh_inspector = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0f8r9byajj3bi2c7c5sqrc7m0zrv3nblfcd4782lw5l73cbsgk04";
      type = "gem";
    };
    version = "1.1.3";
  };
  google-apis-androidpublisher_v3 = {
    dependencies = ["google-apis-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ks2ak4fcvlflhyinykvd88g2ybxwsbc347aww349zhn1mqprbvg";
      type = "gem";
    };
    version = "0.42.0";
  };
  google-apis-core = {
    dependencies = ["addressable" "googleauth" "httpclient" "mini_mime" "representable" "retriable" "rexml" "webrick"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "184zkm5agi7r5fl79hgahjpydsc4d23nd2ynh2sr9z8gs2w4h82f";
      type = "gem";
    };
    version = "0.11.0";
  };
  google-apis-iamcredentials_v1 = {
    dependencies = ["google-apis-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ysil0bkh755kmf9xvw5szhk1yyh3gqzwfsrbwsrl77gsv7jarcs";
      type = "gem";
    };
    version = "0.17.0";
  };
  google-apis-playcustomapp_v1 = {
    dependencies = ["google-apis-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1mlgwiid5lgg41y7qk8ca9lzhwx5njs25hz5fbf1mdal0kwm37lm";
      type = "gem";
    };
    version = "0.13.0";
  };
  google-apis-storage_v1 = {
    dependencies = ["google-apis-core"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17qamcjnf22zvw1g169g8a2gkzdsxx4ij3a4ganihyrcf9r62asj";
      type = "gem";
    };
    version = "0.19.0";
  };
  google-cloud-core = {
    dependencies = ["google-cloud-env" "google-cloud-errors"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0amp8vd16pzbdrfbp7k0k38rqxpwd88bkyp35l3x719hbb6l85za";
      type = "gem";
    };
    version = "1.6.0";
  };
  google-cloud-env = {
    dependencies = ["faraday"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "05gshdqscg4kil6ppfzmikyavsx449bxyj47j33r4n4p8swsqyb1";
      type = "gem";
    };
    version = "1.6.0";
  };
  google-cloud-errors = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0flpj7v196c3xsqx4yjb7rjcj8p0by4rhj6qf5zanw4p1i41ssf0";
      type = "gem";
    };
    version = "1.3.1";
  };
  google-cloud-storage = {
    dependencies = ["addressable" "digest-crc" "google-apis-iamcredentials_v1" "google-apis-storage_v1" "google-cloud-core" "googleauth" "mini_mime"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1skhlpcykxxzw3050cwngdyc3n746wfx443w1w9chxwjbh2ix6i9";
      type = "gem";
    };
    version = "1.44.0";
  };
  googleauth = {
    dependencies = ["faraday" "jwt" "memoist" "multi_json" "os" "signet"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1lj5haarpn7rybbq9s031zcn9ji3rlz5bk64bwa2j34q5s1h5gis";
      type = "gem";
    };
    version = "1.5.2";
  };
  highline = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0yclf57n2j3cw8144ania99h1zinf8q3f5zrhqa754j6gl95rp9d";
      type = "gem";
    };
    version = "2.0.3";
  };
  http-cookie = {
    dependencies = ["domain_name"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13rilvlv8kwbzqfb644qp6hrbsj82cbqmnzcvqip1p6vqx36sxbk";
      type = "gem";
    };
    version = "1.0.5";
  };
  httpclient = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "19mxmvghp7ki3klsxwrlwr431li7hm1lczhhj8z4qihl2acy8l99";
      type = "gem";
    };
    version = "2.8.3";
  };
  i18n = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yk33slipi3i1kydzrrchbi7cgisaxym6pgwlzx7ir8vjk6wl90x";
      type = "gem";
    };
    version = "1.13.0";
  };
  jmespath = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1cdw9vw2qly7q7r41s7phnac264rbsdqgj4l0h4nqgbjb157g393";
      type = "gem";
    };
    version = "1.6.2";
  };
  json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0nalhin1gda4v8ybk6lq8f407cgfrj6qzn234yra4ipkmlbfmal6";
      type = "gem";
    };
    version = "2.6.3";
  };
  jwt = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09yj3z5snhaawh2z1w45yyihzmh57m6m7dp8ra8gxavhj5kbiq5p";
      type = "gem";
    };
    version = "2.7.0";
  };
  memoist = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0i9wpzix3sjhf6d9zw60dm4371iq8kyz7ckh2qapan2vyaim6b55";
      type = "gem";
    };
    version = "0.16.2";
  };
  mini_magick = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0slh78f9z6n0l1i2km7m48yz7l4fjrk88sj1f4mh1wb39sl2yc37";
      type = "gem";
    };
    version = "4.12.0";
  };
  mini_mime = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0lbim375gw2dk6383qirz13hgdmxlan0vc5da2l072j3qw6fqjm5";
      type = "gem";
    };
    version = "1.1.2";
  };
  minitest = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0ic7i5z88zcaqnpzprf7saimq2f6sad57g5mkkqsrqrcd6h3mx06";
      type = "gem";
    };
    version = "5.18.0";
  };
  molinillo = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0p846facmh1j5xmbrpgzadflspvk7bzs3sykrh5s7qi4cdqz5gzg";
      type = "gem";
    };
    version = "0.8.0";
  };
  multi_json = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0pb1g1y3dsiahavspyzkdy39j4q377009f6ix0bh1ag4nqw43l0z";
      type = "gem";
    };
    version = "1.15.0";
  };
  multipart-post = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "09k0b3cybqilk1gwrwwain95rdypixb2q9w65gd44gfzsd84xi1x";
      type = "gem";
    };
    version = "2.0.0";
  };
  nanaimo = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xi36h3f7nm8bc2k0b6svpda1lyank2gf872lxjbhw3h95hdrbma";
      type = "gem";
    };
    version = "0.3.0";
  };
  nap = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0xm5xssxk5s03wjarpipfm39qmgxsalb46v1prsis14x1xk935ll";
      type = "gem";
    };
    version = "1.1.0";
  };
  naturally = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "04x1nkx6gkqzlc4phdvq05v3vjds6mgqhjqzqpcs6vdh5xyqrf59";
      type = "gem";
    };
    version = "2.2.1";
  };
  netrc = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gzfmcywp1da8nzfqsql2zqi648mfnx6qwkig3cv36n9m0yy676y";
      type = "gem";
    };
    version = "0.11.0";
  };
  optparse = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j9l5a1zszvrlggp1ldx82i4kkqx34g4g3amwp488s499w5l1cvj";
      type = "gem";
    };
    version = "0.1.1";
  };
  os = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gwd20smyhxbm687vdikfh1gpi96h8qb1x28s2pdcysf6dm6v0ap";
      type = "gem";
    };
    version = "1.1.4";
  };
  parallel = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0jcc512l38c0c163ni3jgskvq1vc3mr8ly5pvjijzwvfml9lf597";
      type = "gem";
    };
    version = "1.23.0";
  };
  parser = {
    dependencies = ["ast"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08f89nssj7ws7sjfvc2fcjpfm83sjgmniyh0npnmpqf5sfv44r8x";
      type = "gem";
    };
    version = "3.2.2.1";
  };
  plist = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0wzhnbzraz60paxhm48c50fp9xi7cqka4gfhxmiq43mhgh5ajg3h";
      type = "gem";
    };
    version = "3.7.0";
  };
  public_suffix = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1f3knlwfwm05sfbaihrxm4g772b79032q14c16q4b38z8bi63qcb";
      type = "gem";
    };
    version = "4.0.7";
  };
  rainbow = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0smwg4mii0fm38pyb5fddbmrdpifwv22zv3d3px2xx497am93503";
      type = "gem";
    };
    version = "3.1.1";
  };
  rake = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "15whn7p9nrkxangbs9hh75q585yfn66lv0v2mhj6q6dl6x8bzr2w";
      type = "gem";
    };
    version = "13.0.6";
  };
  regexp_parser = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "17xizkw5ryw8hhq64iqxmzdrrdxpc5lhkqc1fgm1aj0zsk1r2950";
      type = "gem";
    };
    version = "2.8.0";
  };
  representable = {
    dependencies = ["declarative" "trailblazer-option" "uber"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1kms3r6w6pnryysnaqqa9fsn0v73zx1ilds9d1c565n3xdzbyafc";
      type = "gem";
    };
    version = "3.2.0";
  };
  retriable = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1q48hqws2dy1vws9schc0kmina40gy7sn5qsndpsfqdslh65snha";
      type = "gem";
    };
    version = "3.1.2";
  };
  rexml = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "08ximcyfjy94pm1rhcx04ny1vx2sk0x4y185gzn86yfsbzwkng53";
      type = "gem";
    };
    version = "3.2.5";
  };
  rouge = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0sfikq1q8xyqqx690iiz7ybhzx87am4w50w8f2nq36l3asw4x89d";
      type = "gem";
    };
    version = "2.0.7";
  };
  rubocop = {
    dependencies = ["json" "parallel" "parser" "rainbow" "regexp_parser" "rexml" "rubocop-ast" "ruby-progressbar" "unicode-display_width"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0013mnzj6ql3v8nif7fm8n2832jnwa46azync6azsg9d4iblrfmy";
      type = "gem";
    };
    version = "1.51.0";
  };
  rubocop-ast = {
    dependencies = ["parser"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0gs8zjigzdqj0kcmmrhvd4zavwr6kz6h9qvrh9m7bhy56f4aqljs";
      type = "gem";
    };
    version = "1.28.1";
  };
  ruby-macho = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1jgmhj4srl7cck1ipbjys6q4klcs473gq90bm59baw4j1wpfaxch";
      type = "gem";
    };
    version = "2.5.1";
  };
  ruby-progressbar = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0cwvyb7j47m7wihpfaq7rc47zwwx9k4v7iqd9s1xch5nm53rrz40";
      type = "gem";
    };
    version = "1.13.0";
  };
  ruby2_keywords = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1vz322p8n39hz3b4a9gkmz9y7a5jaz41zrm2ywf31dvkqm03glgz";
      type = "gem";
    };
    version = "0.0.5";
  };
  rubyzip = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0grps9197qyxakbpw02pda59v45lfgbgiyw48i0mq9f2bn9y6mrz";
      type = "gem";
    };
    version = "2.3.2";
  };
  security = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1ryjxs0j66wrbky2c08yf0mllwalvpg12rpxzbdx2rdhj3cbrlxa";
      type = "gem";
    };
    version = "0.1.3";
  };
  signet = {
    dependencies = ["addressable" "faraday" "jwt" "multi_json"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0100rclkhagf032rg3r0gf3f4znrvvvqrimy6hpa73f21n9k2a0x";
      type = "gem";
    };
    version = "0.17.0";
  };
  simctl = {
    dependencies = ["CFPropertyList" "naturally"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0sr3z4kmp6ym7synicyilj9vic7i9nxgaszqx6n1xn1ss7s7g45r";
      type = "gem";
    };
    version = "1.6.10";
  };
  terminal-notifier = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1slc0y8pjpw30hy21v8ypafi8r7z9jlj4bjbgz03b65b28i2n3bs";
      type = "gem";
    };
    version = "2.0.0";
  };
  terminal-table = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hbmzfr17ji5ws5x5z3kypmb5irwwss7q7kkad0gs005ibqrxv0a";
      type = "gem";
    };
    version = "1.6.0";
  };
  trailblazer-option = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18s48fndi2kfvrfzmq6rxvjfwad347548yby0341ixz1lhpg3r10";
      type = "gem";
    };
    version = "0.1.2";
  };
  tty-cursor = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0j5zw041jgkmn605ya1zc151bxgxl6v192v2i26qhxx7ws2l2lvr";
      type = "gem";
    };
    version = "0.7.1";
  };
  tty-screen = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "18jr6s1cg8yb26wzkqa6874q0z93rq0y5aw092kdqazk71y6a235";
      type = "gem";
    };
    version = "0.8.1";
  };
  tty-spinner = {
    dependencies = ["tty-cursor"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0hh5awmijnzw9flmh5ak610x1d00xiqagxa5mbr63ysggc26y0qf";
      type = "gem";
    };
    version = "0.9.3";
  };
  typhoeus = {
    dependencies = ["ethon"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1m22yrkmbj81rzhlny81j427qdvz57yk5wbcf3km0nf3bl6qiygz";
      type = "gem";
    };
    version = "1.4.0";
  };
  tzinfo = {
    dependencies = ["concurrent-ruby"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "16w2g84dzaf3z13gxyzlzbf748kylk5bdgg3n1ipvkvvqy685bwd";
      type = "gem";
    };
    version = "2.0.6";
  };
  uber = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1p1mm7mngg40x05z52md3mbamkng0zpajbzqjjwmsyw0zw3v9vjv";
      type = "gem";
    };
    version = "0.1.0";
  };
  unf = {
    dependencies = ["unf_ext"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "0bh2cf73i2ffh4fcpdn9ir4mhq8zi50ik0zqa1braahzadx536a9";
      type = "gem";
    };
    version = "0.1.4";
  };
  unf_ext = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1yj2nz2l101vr1x9w2k83a0fag1xgnmjwp8w8rw4ik2rwcz65fch";
      type = "gem";
    };
    version = "0.0.8.2";
  };
  unicode-display_width = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1gi82k102q7bkmfi7ggn9ciypn897ylln1jk9q67kjhr39fj043a";
      type = "gem";
    };
    version = "2.4.2";
  };
  webrick = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "13qm7s0gr2pmfcl7dxrmq38asaza4w0i2n9my4yzs499j731wh8r";
      type = "gem";
    };
    version = "1.8.1";
  };
  word_wrap = {
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1iyc5bc7dbgsd8j3yk1i99ral39f23l6wapi0083fbl19hid8mpm";
      type = "gem";
    };
    version = "1.0.0";
  };
  xcodeproj = {
    dependencies = ["CFPropertyList" "atomos" "claide" "colored2" "nanaimo" "rexml"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1s7hxaqd1fi4rlmm2jbrglyvka1r95frlxan61vfcnd8n6pxynpi";
      type = "gem";
    };
    version = "1.22.0";
  };
  xcpretty = {
    dependencies = ["rouge"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "1xq47q2h5llj7b54rws4796904vnnjz7qqnacdv7wlp3gdbwrivm";
      type = "gem";
    };
    version = "0.3.0";
  };
  xcpretty-travis-formatter = {
    dependencies = ["xcpretty"];
    groups = ["default"];
    platforms = [];
    source = {
      remotes = ["https://rubygems.org"];
      sha256 = "14rg4f70klrs910n7rsgfa4dn8s2qyny55194ax2qyyb2wpk7k5a";
      type = "gem";
    };
    version = "1.0.1";
  };
}
