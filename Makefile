.PHONY: ios-beta ios-ship ios-release ios-promo \
        android-internal android-alpha android-deploy \
        ship release

# ── iOS ──────────────────────────────────────────────
# TestFlight 업로드 (빌드 번호 bump 없음)
ios-beta:
	cd ios && fastlane beta

# 빌드 번호 자동 증가 + TestFlight 업로드
ios-ship:
	cd ios && fastlane ship

# App Store 업로드 (심사 제출은 App Store Connect에서 수동)
ios-release:
	cd ios && fastlane release

# 프로모션 텍스트만 업데이트 (빌드/심사 없이 즉시 반영)
ios-promo:
	cd ios && fastlane promo

# ── Android ──────────────────────────────────────────
# 비공개 테스트 트랙 업로드 (draft)
android-internal:
	cd android && fastlane internal

# 클로즈드 테스트 트랙 업로드
android-alpha:
	cd android && fastlane alpha

# 프로덕션 배포
android-deploy:
	cd android && fastlane deploy

# ── 동시 배포 ─────────────────────────────────────────
# iOS(TestFlight) + Android(비공개 테스트) 동시 업로드
ship:
	cd ios && fastlane ship & cd android && fastlane internal & wait

# iOS(App Store) + Android(프로덕션) 동시 업로드
release:
	cd ios && fastlane release & cd android && fastlane deploy & wait
