# 찾아부기 - 한성대 학우들을 위한 분실물 커뮤니티 앱 

2024학년 3학년 2학기 고급모바일프로그래밍 프로젝트입니다.

## 프로젝트 개요

찾아부기는 한성대학교 학생들이 분실물을 쉽고 빠르게 찾을 수 있도록 돕는 **분실물 커뮤니티 플랫폼**이다.\
우리는 학교에서 물건을 분실했을 때, 누군가가 습득하여 ‘에브리타임’이나 원스톱지원센터에 맡기지 않으면 물건을 찾는 것에 매우 어려움을 겪었다.\
그래서 이러한 불편함을 해소하기 위해 학생들이 직접 분실물과 습득물을 쉽게 등록하고 찾을 수 있는 서비스를 기획했다.\
또한 찾아부기는 단순히 분실물을 찾는 데 그치지 않고 학생들 간 소통과 협력을 촉진하여 서로를 돕는 긍정적인 공동체 문화를 형성하는 것을 목표로 하고 있다.

## 적용 기술
개발환경 : Flutter\
개발 언어 : dart\
개발 도구 : Android Studio, Firebase, mySQL

## 프로젝트 기능
홈화면
- 상단바에는 검색 기능과 알림창, 마이페이지로 이동할 수 있는 아이콘
- 게시글을 습득물과 분실물로 나누어 게시할 수 있으며, 각각의 탭에서 분류된 게시글을 확인 가능
- 학교 내의 대표 분실물 보관소를 장소 카테고리로 설정하여, 원하는 장소를 선택하면 해당 장소에 대한 게시글을 확인 가능
- 게시글은 제목, 키워드, 작성 시간과 대표 이미지 정보를 제공하여 카드 형식으로 나열
- 마이페이지, 채팅, 게시글 작성은 로그인을 해야 가능

로그인
- 로그인은 한성대학교 종합정보시스템의 학번과 비밀번호로 로그인할 수 있음.
- 자동로그인을 누르면 앱 재실행 시 로그인을 생략할 수 있음.

게시글 작성
- 제목은 3자 이상, 본문은 10자 이상으로 작성해야함.
- 키워드 버튼을 누르면 분실한 물건과 장소를 선택할 수 있는 다이얼로그가 나옴.
- 키워드는 물건과 장소 필수로 지정해야 하며,  이 키워드로 사용자가 쉽게 게시글 검색할 수 있음.
- 만약 글자 수 조건을 만족하지 않거나 키워드를 선택하지 않으면 게시글을 등록 할 수 없음.
- 카메라 버튼을 누르면 자신의 갤러리에 있는 이미지를 최대 4개까지 업로드 할 수 있음.

게시글 검색
- 특정 키워드를 입력하면, 해당 키워드와 관련된 분실물 또는 습득물의 게시글이 리스트 형태로 정렬되어 나타남.
- 검색 결과는 최신 게시물 순으로 정리되며, 사용자는 게시글을 클릭하여 상세 정보를 확인하거나 직접 작성자와 소통할 수 있음.
- 실시간 검색어는 현재 가장 많이 검색된 단어들이 실시간으로 업데이트되어 사용자에게 표시됨.
- 사용자는 가장 많이 검색된 물건이나 장소를 빠르게 파악할 수 있음.
- 최근에 검색한 키워드가 화면에 표시됨.

지도 
- 대표 분실물 보관 장소의 위치와 최근 일주일 이내 등록된 분실물 데이터를 한눈에 파악할 수 있도록 설계됨.
- 상상부기 마커를 통해 주요 분실물 보관 장소를 직관적으로 확인 가능.
- 상상부기 마커는 단순히 위치를 나타내는 역할을 넘어, 각 장소별로 최근 일주일 이내 등록된 습득물 개수를 시각적으로 제공하여, 사용자들이 빠르게 현황을 파악할 수 있도록 도움.
- 사용자가 부기 마커를 클릭하면, 해당 장소와 관련된 습득물 리스트가 화면에 표시됨.
- 습득물 상세 정보를 제공하며, 사용자는 이를 통해 원하는 게시물로 즉시 이동할 수 있음.

채팅 및 쪽지
- 채팅 및 쪽지 기능을 제공.
- 실시간으로 다른 사용자와 메시지를 주고받으며, 분실물 및 습득물 정보 공유 가능.
- 각 채팅은 어떤 게시글에서 시작된 대화인지 확인 가능하여, 대화의 맥락을 놓치지 않고 이어갈 수 있음.
- 상단에는 마지막 대화 날짜 또는 현재 날짜가 표시됨.
- 읽지 않은 쪽지는 빨간색 숫자 표시로 구분되어, 사용자가 새 쪽지를 놓치지 않고 확인할 수 있음.

마이페이지
- 마이페이지에서는 나의 프로필, 뱃지, 댓글과 같은 다양한 활동 내역을 볼 수 있으며 공지사항도 확인할 수 있음.
- 프로필에서는 프로필 이미지와 닉네임 변경 기능을 제공함.
- 처음 로그인 시, 기본 프로필은 부기 이미지와 함께 "부기1234"와 같은 랜덤 닉네임이 자동으로 설정됨.
- 사용자의 활동 기록에 따라 다양한 뱃지가 부여되며, 성취감을 제공함.
- 첫 댓글 작성, 첫 게시글 작성 시 각각 뱃지를 획득.
- 나의 활동에서는 내 게시글과 댓글 단 글을 볼 수 있어 자신이 작성한 게시글과 댓글 단 게시글을 리스트로 확인이 가능.
- 공지사항은 찾아부기의 관리자가 작성한 공지사항 전체 리스트를 확인할 수 있음.
- 사용자는 전체 공지사항 리스트를 열람하며, 새로운 소식과 업데이트 내용을 놓치지 않을 수 있음.
- 로그아웃을 클릭하면 계정이 로그에서 false 값으로 바뀌면서 로그아웃 됨.

공지사항
- 관리자 권한을 가진 사용자는 공지사항 화면에서 글 작성 버튼이 활성화되며, 새로운 공지사항을 작성할 수 있음.
- 일반 사용자는 공지사항 화면에서 작성된 공지사항 글을 열람하는 기능만 제공됨.
- 제일 최근에 올라온 공지사항 1건은 항상 게시글 전체 키워드 리스트에 노란색 카드로 노출됨.

## 팀원

