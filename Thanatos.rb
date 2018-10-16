::RBNACL_LIBSODIUM_GEM_LIB_PATH = "C:/DevKit/libsodium.dll"
require 'discordrb'
require 'open-uri'
require 'opus-ruby'
require 'ffi'
require 'youtube-dl'
require 'date'

bot = Discordrb::Commands::CommandBot.new token:'', client_id:, prefix:'!' #Declaracao do Token, Client_ID e Prefixo usado pelo Bot

$poke_hour = 0
$isplaying = 0
$pokemon_display

class Pokedex
  $pokemon_name
  def randomize_generation
    number = rand(1..808)
    if number < 152
      generation = 1
    elsif number > 151 and number < 252
      generation = 2
      number = number - 151
    elsif number > 251 and number < 387
      generation = 3
      number = number - 251
    elsif number > 386 and number < 494
      generation = 4
      number = number - 386
    elsif number > 493 and number < 650
      generation = 5
      number = number - 493
    else
      generation = 6
      number = number - 649
    end
    dir = "C:/Users/Pulhote/Desktop/Thanatos/discordrb/lib/Pokedex/geracao" + generation.to_s + ".txt"
    
    File.open(dir)
    line = IO.readlines(dir)[number]

    if line == nil
      
    else
      $pokemon_name = line.chop
      pokemon = line.downcase
      pokemon = pokemon.chop + ".gif"
      pokedir = "https://img.pokemondb.net/sprites/black-white/anim/normal/" + pokemon
      download = open(pokedir)
      IO.copy_stream(download, 'C:/Users/Pulhote/Desktop/Thanatos/discordrb/lib/Pokedex/gif/display.gif')
      end
  end

  def timer_pokemon
    actual_minute = DateTime.now
    minute = actual_minute.strftime("%M")

    if (minute == 00 || minute == 15 || minute == 30 || minute == 45 || minute == 50)
      if $poke_hour == 0
        $poke_hour = 1
        comand_timer = rand(5..60)
        event.server.general_channel.send_message "Pokemons estão a espreita, fique atento!".force_encoding(Encoding::UTF_8)
        sleep(comand_timer)
        pokedex.randomize_generation
        event.server.general_channel.send_message  "#{$pokemon_name} Apareceu!"
        file = event.server.general_channel.send_message (File.open("C:/Users/Pulhote/Desktop/Thanatos/discordrb/lib/Pokedex/gif/display.gif", 'r'))
        catch_helper = event.server.general_channel.send_message  "Digite ''!catch'' para pega-lo!"
      else
        $poke_hour = 0
      end
    end
  end
end

bot.mention do |event|
  event.respond "Comandos de Chat:\n!ping\n!help {Comando}\n!count {Número}\n!invite\n!netflix\n!pokemon\n!catch\nHehe, por enquanto é só isso guys\n
Comandos chat de voz ( não disponiveis ainda ):\n!join\n!leave\n!play {link/nome}\n!pause\n!continue\n!stop".force_encoding(Encoding::UTF_8) # Responde no chat em que o usuario inseriu o comando
end

bot.command :ping do |event|
  event.respond "#{(event.timestamp - Time.now ).round}ms" # Tempo de resposta com aproximacao de Inteiro mais proximo
end

bot.command :count do |event, message|
  count = message.to_i
  if (count > 10) or (count < -10)
    event.respond "Valor inválido, digite valores entre módulo de 10".force_encoding(Encoding::UTF_8)
  else

    if count < 0
      event.respond "Ta de gracinha é?".force_encoding(Encoding::UTF_8)
      while count != 0 do
        event.respond "#{count}"
        count = count + 1
        sleep(1)
      end
      event.respond "GO!"
    else
      while count != 0 do
        event.respond "#{count}. . ."
        count = count - 1
        sleep(1)
      end
      event.respond "GO!"
    end

  end
end

bot.command :join do |event|
  channel = event.user.voice_channel
  next event.respond "Voce não esta em nenhum canal de voz" unless channel
  event.respond "Conectado ao canal de voz: #{channel.name}"
  bot.voice_connect(channel)
  nil
end

bot.command :leave do |event|
  bot.voices[event.server.id].destroy
  nil
end

bot.command :invite do |event| # Enviar link de invite do Bot para outros servidores
  event.respond "#{event.user.mention} verifique sua caixa de mensagens privadas ;)"
  event.user.pm "Ainda estou em desenvolvimento, mas você me aceitar no servidor é de grande ajuda :D\nhttps://discordapp.com/oauth2/authorize?client_id=408656896497549312&scope=bot".force_encoding(Encoding::UTF_8)
end

bot.command :help do |event, message|
  if message == nil
    event.respond "#{event.user.mention} verifique sua caixa de mensagens privadas ;)"
    event.message.delete # Deletar mensagem de !help
    event.user.pm "Comandos de Chat:\n!ping\n!help {Comando}\n!count {Número}\n!invite\n!netflix\n!pokemon\n!catch\nHehe, por enquanto é só isso guys\n
Comandos chat de voz ( não disponiveis ainda ):\n!join\n!leave\n!play {link/nome}\n!pause\n!continue\n!stop".force_encoding(Encoding::UTF_8) # Envia como mensagem privada para o usuario
  
  else # Explanacao das funcoes
    message = message.downcase # Transformar a mensagem recebida do usuario em caixa baixa
    case message

    when "ping"
      event.respond "Averiguar o tempo resposta do Bot no servidor" 
    when "count"
      event.respond "Contagem regressiva do valor inserido"
    when "play"
      event.respond "Tocar musica no servidor ( Requer estar usuario em canal de voz )"
    when "stop"
      event.respond "Parar playlist atual de musicas que estao tocando"
    when "continue"
      event.respond "Voltar a tocar a musica que estava em andamento"
    when "pause"
      event.respond "Pausar a musica que estava a tocar"
    when "invite"
      event.respond "Comando para me invitar para o seu servidor! :D"
    when "netflix"
      event.respond "Saiba da ultima novidade da netflix sem precisar de muito esforço!"
    when "pokemon"
      event.respond "Veja se tem algum pokemon a espreita!"
    when "catch"
      event.respond "Capture o pokemon caso ache algum"
    else
      event.respond "Não faco ideia que comando seja esse...".force_encoding(Encoding::UTF_8)
    end
  end
end

bot.command :pause do |event|
  event.voice.pause
  $continue = event.respond "Digite ''!continue'' para voltar a tocar"
  $continuesupport = 1
  nil
end
  
bot.command :continue do |event|
  $continuesupport = 0
  event.voice.continue
  $continue.delete
  nil
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

bot.command :play do |event, songlink|
  if $isplaying == 1
    event.message.delete
    event.respond 'Já existe música em reprodução, aguarde'.force_encoding(Encoding::UTF_8)
    break
  end
  channel = event.user.voice_channel
  unless channel.nil?
    voice_bot = bot.voice_connect(channel)
    YoutubeDL.download "#{songlink}", output: 'Audio.mp3'
    event.respond "Playing now"
    $isplaying = 1
    voice_bot.play_file('Audio.mp3')
    bot.voices[event.server.id].destroy
    $isplaying = 0
    break
  end
end

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -#

bot.command :music_test do |event| 
  $isplaying = 1
  channel = event.user.voice_channel
  bot.voice_connect(channel)
  voice_bot = event.voice
  voice_bot.play_file('C:/Users/Pulhote/Desktop/Thanatos/Songs/Audio.mp3')
end

bot.command :stop do |event|
  $isplaying = 0
  if $continuesupport == 1
    $continue.delete
  end
  event.voice.stop_playing
  bot.voices[event.server.id].destroy
  nil
end

bot.command :netflix do |event|
  x = event.respond "Averiguando novidades... aguarde!"
  netflix_image = event.send_file(File.open("C:/Users/Pulhote/Desktop/Thanatos/Logo/netflixlogo.png", 'r'))
  download = open('https://www.facebook.com/netflixbrasil/')
  IO.copy_stream(download, 'C:/Users/Pulhote/Desktop/Thanatos/netflix.html')
  $str = String.new
  File.open("C:/Users/Pulhote/Desktop/Thanatos/netflix.html") do |infile|
    support = 1
    while ( support == 1 )
      line = infile.gets
      if line.include? ('<p>')
        support = 0
      end
    end
    
    regex = /\<p>(.*?)<div/
    line = line.slice(regex, 1)
    size_t = line.length - 1
    text = String.new
    support = 0
    k = 0

    (0..size_t).each do |i|
      if line[i] == '<'
        support = 1
     
      elsif line[i] == '>'
        support = 0
      
      end
      if support == 0 
        text[k] = line[i]
        k = k + 1
      end
    end
    text = text.delete! '>'
    text =  text.force_encoding(Encoding::UTF_8)
    netflix_image.delete
    x.edit "Novidades da netflix!\n\n''#{text}''"
  end
end

bot.command :pokemon do |event|
  lucky = rand(0..10)
  if lucky > 6
    pokedex = Pokedex.new
    pokedex.randomize_generation
    appears = event.respond "#{$pokemon_name} Apareceu!"
    file = event.send_file(File.open("C:/Users/Pulhote/Desktop/Thanatos/discordrb/lib/Pokedex/gif/display.gif", 'r'))
    catch_helper = event.respond "Digite ''!catch'' para pega-lo!"
  else
    event.respond "Nenhum pokemon por perto. Tente novamente mais tarde!"
  end 
end

bot.command :catch do |event|
  event.respond "#{event.user.mention} foi mais rápido e adicionou #{$pokemon_name} na sua pokedex!"
end

bot.run
