-- VLC extension to simulate watching TV
function descriptor()
    return {
        title = "Watch TV",
        version = "1.0",
        author = "dichipan",
        capabilities = {"menu"}
    }
end

-- Get all video files from a directory recursively
function get_video_files(directory)
    local files = {}
    local supported_extensions = {
        [".mp4"] = true,
        [".mkv"] = true,
        [".avi"] = true,
        [".mov"] = true,
        [".wmv"] = true
    }
    
    -- List all files in directory
    local command = 'dir "' .. directory .. '" /b /s /a-d'
    local handle = io.popen(command)
    local result = handle:read("*a")
    handle:close()
    
    -- Process each file
    for path in string.gmatch(result, "[^\r\n]+") do
        -- Check if file has supported extension
        local ext = string.match(path, "%.%w+$")
        if ext and supported_extensions[string.lower(ext)] then
            table.insert(files, path)
        end
    end
    
    return files
end

-- Shuffles table
function shuffle_table(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i]
    end
end

-- Global variable to hold the shuffled playlist
local shuffled_playlist = {}

-- Start playing the shuffled playlist
function start_playlist()
    -- Clear current playlist
    vlc.playlist.clear()
    
    -- Add all files to playlist
    for _, file in ipairs(shuffled_playlist) do
        local uri = "file:///" .. string.gsub(file, "\\", "/")
        vlc.playlist.add({{path = uri}})
        vlc.msg.info("Added to playlist: " .. uri)
    end
    
    -- Start playing
    vlc.playlist.play()
    vlc.msg.info("Started shuffled playlist with " .. #shuffled_playlist .. " videos")
end

-- Begins next video in playlist upon video stopped
function on_playback_stopped()
    vlc.msg.info("Video finished, playing next video...")
    vlc.playlist.next()
end

-- Notifies playlist playing
function on_playlist_playing()
    vlc.msg.info("Playlist is playing")
end

function activate()
    -- Set the directory paths
    local shows_directory = "C:/path/to/shows/folder/"
    local commercials_directory = "C:/path/to/commercials/folder/"
    
    -- Get video files for shows and commercials
    local show_files = get_video_files(shows_directory)
    local commercial_files = get_video_files(commercials_directory)
    
    if #show_files == 0 then
        vlc.msg.info("No show videos found in directory")
        return
    end
    
    if #commercial_files == 0 then
        vlc.msg.info("No commercial videos found in directory")
        return
    end
    
    -- Seed random number generator
    math.randomseed(os.time())
    
    -- Shuffle the show files
    shuffle_table(show_files)
    
    -- Shuffle the commercial files
    shuffle_table(commercial_files)
    
    -- Create the shuffled playlist by alternating shows and commercials
    shuffled_playlist = {}
    
    local show_index = 1
    local commercial_index = 1

    -- Alternate between show and commercial, inserting 5-8 commercials after each show
    while show_index <= #show_files do
        -- Add a show to the playlist
        if show_index <= #show_files then
            table.insert(shuffled_playlist, show_files[show_index])
            show_index = show_index + 1
        end
        
        -- Add a random number of commercials (between 5 and 8)
        local num_commercials = math.random(5, 8)
        for i = 1, num_commercials do
            if commercial_index <= #commercial_files then
                table.insert(shuffled_playlist, commercial_files[commercial_index])
                commercial_index = commercial_index + 1
            end
        end
    end
    
    -- Handles VLC bug where two shows will play in succession at the start, probably a better solution
    table.remove(shuffled_playlist, 1)

    -- Start playing the shuffled playlist
    start_playlist()
    
    -- Binds functions to playlist actions
    vlc.playlist.event.attach(vlc.playlist.Playing, on_playlist_playing)
    vlc.playlist.event.attach(vlc.playlist.Ended, on_playback_stopped)
end

function deactivate()
    vlc.msg.info("TV Simulator extension deactivated")
end

function close()
    vlc.deactivate()
end

-- Add menu item
function menu()
    return {"Shuffle TV shows with commercials between each episode"}
end

-- Handle menu selection
function trigger_menu(id)
    if id == 1 then
        activate()
    end
end
