local jukebox_default_tracks = MusicManager.jukebox_default_tracks
function MusicManager:jukebox_default_tracks()
    local trax = jukebox_default_tracks(self)
    
    trax.heist_pre1_name = "jungle"
    trax.heist_pre2_name = "synth"
    
    return trax
end