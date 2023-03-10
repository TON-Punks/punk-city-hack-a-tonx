module TelegramRequestHelper
  def build_telegram_request(chat_id: 123, text: '')
    message = {
      chat: {
        id: chat_id,
        type: 'private',
        username: 'Test Username',
      },
      from: {
        id: chat_id,
        username: 'Test Username',
        language_code: 'en'
      }
    }
    message = message.merge(text: text) if text
    TelegramRequest.new(message: message)
  end

  def build_telegram_group_message(text: '')
    message = {
      chat: {
        id: -123,
        type: 'group',
        title: 'Group title',
      },
      from: {
        id: 123,
        username: 'Test Username',
        language_code: 'en'
      }
    }
    message = message.merge(text: text) if text
    TelegramRequest.new(message: message)
  end

  def build_telegram_callback_query(data: '', options: {})
    query = {
      id: 12399,
      data: data,
      message: {
        message_id: 12233,
        chat: {
          id: -123,
          type: 'group',
          title: 'Group title',
        },
        from: {
          id: 123,
          username: 'Test Username',
          language_code: 'en'
        }
      },
      from: {
          id: 123,
          username: 'Test Username',
          language_code: 'en'
        }
    }
    TelegramRequest.new(options.reverse_merge(callback_query: query))
  end

  def build_telegram_forward_request(chat_id: '123', forward_id: '123', title: 'Chat Title', username: 'User Name')
    message = {
      chat: {
        id: chat_id,
        type: 'private',
        username: 'Test Username',
      },
      from: {
        id: chat_id,
        type: 'private',
        username: 'Test Username',
        language_code: 'en'
      },
      forward_from_chat: {
        id: '-123',
        username:  username,
        title: title,
        forward_id: forward_id,
        type: 'channel'
      }
    }

    TelegramRequest.new(message: message)
  end

  def build_telegram_update_request(chat_id: '123', status:)
    my_chat_member = {
      chat: {
        id: chat_id,
        type: 'private',
        username: 'Test Username',
      },
      from: {
        id: chat_id,
        type: 'private',
        username: 'Test Username',
        language_code: 'en'
      },
      new_chat_member: {
        "user" => {
          "id" => 1330039990,
          "is_bot" => true,
          "first_name" => "Feedgram",
          "username" => "mydigest_bot"
        },
        "status" => status
      }
    }

    TelegramRequest.new(my_chat_member: my_chat_member)
  end

  def stub_telegram
    stub_request(:post, Regexp.new("https://api.telegram.org/*"))
  end
end
