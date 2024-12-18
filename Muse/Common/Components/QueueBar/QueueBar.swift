//
//  QueueBar.swift
//  Muse
//
//  Created by Tamerlan Satualdypov on 31.12.2023.
//

import SwiftUI
import MusicKit

struct QueueBar: View {
    
    @EnvironmentObject private var musicPlayer: MusicPlayer
    
    var body: some View {
        ZStack {
            VStack(spacing: 0.0) {
                
                Group {
                    if self.musicPlayer.queue.isEmpty {
                        Text("There are no songs in the queue")
                            .font(.system(size: 12.0, weight: .medium))
                            .foregroundStyle(Color.secondaryText)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        self.songList
                    }
                }
            }
            .frame(width: 256.0, height: 450.0)
            .frame(maxHeight: .infinity, alignment: .top)
            .background(.ultraThinMaterial)
            .clipShape(.rect(cornerRadius: 12.0))
            .border(style: .quinaryFill, cornerRadius: 12.0)
        }
    }
    
    // MARK: - Components
    
    private var songList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8.0) {
                    ForEach(self.musicPlayer.queue) { song in
                        Item(song: song)
                            .id(song.id)
                    }
                }
                .padding(.all, 16.0)
            }
            .scrollIndicators(.never)
            .onAppear {
                if let currentSongID = self.musicPlayer.currentSong?.id {
                    proxy.scrollTo(currentSongID, anchor: .center)
                }
            }
        }
    }
}

extension QueueBar {
    struct Item: View {
        private let song: Song
        
        @State private var isHovered: Bool = false
        
        @EnvironmentObject private var musicPlayer: MusicPlayer
        
        init(song: Song) {
            self.song = song
        }
        
        var body: some View {
            HStack {
                HStack(spacing: 12.0) {
                    ZStack {
                        MusicArtworkImage(
                            artwork: self.song.artwork,
                            width: 40.0,
                            height: 40.0,
                            imageWidth: 40.0,
                            imageHeight: 40.0
                        )
                        
                        if self.isHovered {
                            Color.black
                                .opacity(0.4)
                            
                            Image(systemName: "play.fill")
                                .font(.system(size: 12.0))
                                .foregroundStyle(Color.white)
                        }
                    }
                    .transition(.opacity)
                    .frame(width: 40.0, height: 40.0)
                    .clipShape(.rect(cornerRadius: 8.0))
                    .border(style: .quinaryFill, cornerRadius: 8.0)
                    
                    VStack(alignment: .leading) {
                        Text(self.song.title)
                            .lineLimit(1)
                            .font(.system(size: 12.0))
                            .foregroundStyle(Color.primary)
                        
                        Text(self.song.artistName)
                            .lineLimit(1)
                            .font(.system(size: 12.0))
                            .foregroundStyle(Color.secondaryText)
                    }
                    .opacity(self.song.id == self.musicPlayer.currentSong?.id ? 1.0 : 0.4)
                }
                .animation(.easeIn(duration: 0.2), value: self.isHovered)
                
                Spacer()
                
                Group {
                    if let duration = self.song.duration?.minutesAndSeconds, !self.isHovered {
                        Text(duration)
                            .font(.system(size: 12.0, weight: .medium))
                            .foregroundStyle(Color.secondaryText)
                    } else {
                        Image(systemName: "trash.fill")
                            .font(.system(size: 14.0, weight: .medium))
                            .foregroundStyle(Color.pinkAccent)
                            .onTapGesture {
                                self.musicPlayer.remove(song: self.song)
                            }
                    }
                }
                .frame(width: 40.0)
            }
            .onHover { hovering in
                self.isHovered = hovering
            }
            .tappable {
                Task {
                    await self.musicPlayer.skip(to: self.song)
                }
            }
        }
    }
}
