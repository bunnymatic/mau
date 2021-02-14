#!/usr/bin/env ruby
spam_accounts = ['attonhayd John <slip23572@tom.com>',
                 'halermary aifseng <casteelwof@hotmail.com>',
                 'ciavarinpatri billaa <dlu0494599774516@163.com>',
                 'neha century <centuryweb97@gmail.com>',
                 'ukandershar John <ruehlgjt@hotmail.com>',
                 'volkingeste aifseng <ca617979945@163.com>',
                 'morejere billaa <waleyuro@hotmail.com>',
                 'olafiaelly aifseng <com66370516244730@163.com>',
                 'askydarr andeson <natianzhu0@163.com>',
                 'milesales aifseng <danzhenyou@sohu.com>',
                 'ejere billaa <siyangchang@sohu.com>',
                 'ayleyhilt billaa <pelliconefl@sohu.com>',
                 'koteydesp andeson <yanzongdqxade@21cn.com>',
                 'astrowbridmaxim John <keilholtzgxv@hotmail.com>',
                 'eawaltclar andeson <danbuyan@sohu.com>',
                 'afrerkinanna aifseng <huangdaichou@sohu.com>',
                 'ermershanewt andeson <suteraaum@hotmail.com>',
                 'chunemanshav aifseng <gunter38837@tom.com>',
                 'ellamonileon aifseng <a5466901797c@yeah.net>',
                 'amperagnu billaa <luna32957@tom.com>',
                 'ahenneyalbe andeson <speieroce@hotmail.com>',
                 'ekrupanskytommy John <fd1cb091f@163.com>',
                 'watchess billaa <gongjingqun@sohu.com>',
                 'allawaycl aifseng <zhangqieugkfeu@21cn.com>',
                 'tiffanyst aifseng <wuyoua3127@yeah.net>',
                 'buyjers John <douxiango20362@yeah.net>',
                 'buyadv John <chengcez11590@163.com>',
                 'parkago billaa <trompjzk@hotmail.com>',
                 'tiffanycobra billaa <barellankv@hotmail.com>',
                 'syntheticl billaa <mpi687596691370@163.com>',
                 'disountdiso John <qudiej09241@163.com>',
                 'northrealiza aifseng <linqiant94791@yeah.net>',
                 'tiffanywedd andeson <yunw9832@yeah.net>',
                 'linkscha andeson <changbieh3432@yeah.net>',
                 'canadianjac John <pray98918@tom.com>',
                 'discountstee aifseng <kill92234@tom.com>',
                 'fullf aifseng <mzz19940046045247@163.com>',
                 'rolexrepl John <d429620c2@163.com>',
                 'choosewonder John <a74ad329b@163.com>',
                 'sanjers aifseng <beixingt16996@163.com>',
                 'sivlerearri aifseng <bc082e8b@163.com>',
                 'mobileph aifseng <year222258@tom.com>',
                 'discountmonc John <hunjiangg600@yeah.net>',
                 'softwareserv John <yaojianv28310@163.com>',
                 'buyf andeson <tongmenvtyfvw@21cn.com>',
                 'babydolls aifseng <beiweip09703@163.com>',
                 'mensbo andeson <zutieazfuxe@21cn.com>',
                 'tiffany aifseng <riverodvn@hotmail.com>',
                 'proms aifseng <torkkeetch@sohu.com>',
                 'theno John <zhuangtiu39341@yeah.net>',
                 'discountwom billaa <channii20396@yeah.net>',
                 'rolex billaa <feikaiz1540@163.com>',
                 'mau test artist <asdfas@b.com>']

spam_accounts.each do |acct|
  m = /<(.*)>/.match(acct)
  next unless m

  email = m[1]
  a = Artist.find_by(email: email)
  if a
    puts "Removing artist #{a.email}"
    a.destroy
  end
end
