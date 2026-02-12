{ pkgs-unstable, pkgs, lib, inputs, ... }:

let
  fixed-equibop = (pkgs-unstable.equibop.override { electron = pkgs.electron; })
    .overrideAttrs (old: {
      postFixup =
        let
          libPath = with pkgs; lib.makeLibraryPath [
            libva
            stdenv.cc.cc.lib
          ];
        in (old.postFixup or "") + ''
          wrapProgram $out/bin/equibop --prefix LD_LIBRARY_PATH : "${libPath}"
        '';
    });
in {
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];

  programs.nixcord = {
    enable = true;
    discord = {
      enable = false;
      vencord.enable = false;
      equicord.enable = true;
    };
    equibop = {
      enable = true;
      package = fixed-equibop;
    };
    config = {
      /*themeLinks = [
        "https://raw.githubusercontent.com/link/to/some/theme.css"
      ];*/
      frameless = true;
      plugins = {
        # Vencord
        messageLogger = {
          ignoreSelf = true;
          showEditDiffs = true;
        };
        roleColorEverywhere.enable = true;
        accountPanelServerProfile.enable = true;
        alwaysExpandRoles = {
          enable = true;
          hideArrow = true;
        };
        betterFolders.enable = true;
        betterGifAltText.enable = true;
        betterSessions = {
          enable = true;
          backgroundCheck = true;
        };
        betterSettings.enable = true;
        betterUploadButton.enable = true;
        biggerStreamPreview.enable = true;
        ClearURLs.enable = true;
        consoleJanitor.enable = true;
        copyEmojiMarkdown.enable = true;
        copyFileContents.enable = true;
        copyStickerLinks.enable = true;
        crashHandler = {
          enable = true;
          attemptToPreventCrashes = true;
          attemptToNavigateToHome = true;
        };
        disableCallIdle.enable = true;
        decor.enable = true;
        expressionCloner.enable = true;
        fakeNitro.enable = true;
        fakeProfileThemes.enable = true;
        fixImagesQuality.enable = true;
        fixYoutubeEmbeds.enable = true;
        forceOwnerCrown.enable = true;
        friendsSince.enable = true;
        fullSearchContext.enable = true;
        fullUserInChatbox.enable = true;
        gameActivityToggle.enable = true;
        greetStickerPicker.enable = true;
        imageFilename = {
          enable = true;
          showFullUrl = true;
        };
        imageLink.enable = true;
        imageZoom = {
          enable = true;
          size = 1000.0;
          zoom = 4.5;
        };
        implicitRelationships.enable = true;
        memberCount.enable = true;
        mentionAvatars.enable = true;
        messageLatency = {
          enable = true;
          showMillis = true;
        };
        messageLinkEmbeds.enable = true;
        moreQuickReactions = {
          enable = true;
          reactionCount = 10;
        };
        MutualGroupDMs.enable = true;
        noDevtoolsWarning.enable = true;
        noF1.enable = true;
        noOnboardingDelay.enable = true;
        noReplyMention.enable = true;
        normalizeMessageLinks.enable = true;
        noUnblockToJump.enable = true;
        pauseInvitesForever.enable = true;
        permissionsViewer.enable = true;
        petpet.enable = true;
        plainFolderIcon.enable = true;
        platformIndicators.enable = true;
        previewMessage.enable = true;
        quickMention.enable = true;
        reactErrorDecoder.enable = true;
        relationshipNotifier.enable = true;
        replyTimestamp.enable = true;
        revealAllSpoilers.enable = true;
        reverseImageSearch.enable = true;
        ReviewDB.enable = true;
        sendTimestamps = {
          enable = true;
          replaceMessageContents = false;
        };
        serverInfo.enable = true;
        serverListIndicators = {
          enable = true;
          mode = 3;
          useCompact = true;
        };
        shikiCodeblocks = {
          enable = true;
          customTheme = "https://raw.githubusercontent.com/shikijs/textmate-grammars-themes/master/packages/tm-themes/themes/one-dark-pro.json";
        };
        showConnections.enable = true;
        showHiddenChannels.enable = true;
        showHiddenThings.enable = true;
        showMeYourName.enable = true;
        silentTyping.enable = true;
        sortFriendRequests = {
          enable = true;
          showDates = true;
        };
        startupTimings.enable = true;
        stickerPaste.enable = true;
        summaries.enable = true;
        themeAttributes.enable = true;
        translate = {
          enable = true;
          service = "deepl";
        };
        typingIndicator.enable = true;
        typingTweaks.enable = true;
        unindent.enable = true;
        unlockedAvatarZoom.enable = true;
        unsuppressEmbeds.enable = true;
        userMessagesPronouns.enable = true;
        userVoiceShow.enable = true;
        USRBG.enable = true;
        validReply.enable = true;
        validUser.enable = true;
        viewIcons = {
          enable = true;
          format = "png";
        };
        viewRaw.enable = true;
        voiceChatDoubleClick.enable = true;
        voiceDownload.enable = true;
        volumeBooster.enable = true;
        whoReacted.enable = true;
        youtubeAdblock.enable = true;
        # Equicord
        allCallTimers = {
          enable = true;
          showSeconds = true;
          showWithoutHover = true;
        };
        betterAudioPlayer.enable = true;
        characterCounter.enable = true;
        gifCollections.enable = true;
        splitLargeMessages.enable = true;
        whosWatching.enable = true;
        youtubeDescription.enable = true;
      };
    };
    extraConfig = {
      plugins = {
        # Vencord
        OpenInApp = {
          enabled = true;
          epic = false;
        };
        # Equicord
        MessageLoggerEnhanced = {
          enabled = true;
          saveImages = true;
          ignoreSelf = true;
        };
        SoundBoardLogger = {
          enabled = true;
          FileType = ".mp3";
        };
      };
    };
  };
}
