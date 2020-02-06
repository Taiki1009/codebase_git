
$(function() {
// ナビゲーションバー
    $('#nav-1').click(function(){
        $('html, body').animate({
            'scrollTop':0
        },'slow');
    });
    $('#nav-2').click(function(){
        $('html, body').animate({
            'scrollTop':325
        },'slow');
    });
    $('#nav-3').click(function(){
        $('html, body').animate({
            'scrollTop':1000
        },'slow');
    });
    // スクロール量取得
    // $(window).scroll(function() {
    //     console.log($(this).scrollTop());
    // });


// トップ
    $('.information').click(function() {
        let index = $(this).index();
        let btn_num = $('.btn' + index);
        let info_num = $('.info' + index);
        console.log(index + 'th item clicked!');

        if(info_num.hasClass('open')) { 
            info_num.removeClass('open');
            info_num.animate( {width: 'toggle'}, 'slow');

            switch (index) {
                case 1: btn_num.text('Name');
                break;
                case 2: btn_num.text('Affiliation');
                break;
                case 3: btn_num.text('Info');
                break;
            }
        } else {
            info_num.addClass('open'); 
            info_num.animate( {width: 'toggle'}, 'slow');
            btn_num.text('close');
        }
    });


// インフォ-toggle
    // $('.info1').click(function() {
    //     $('.info1 p').animate( {width: 'toggle'}, 'slow');
    // });
    // $('.info2').click(function() {
    //     $('.info2 p').animate( {width: 'toggle'}, 'slow');
    // });
    // $('.info3').click(function() {
    //     $('.info3 p').animate( {width: 'toggle'}, 'slow');
    // });


// モーダル
    $(".btn-modal").click(function() {
        $("#graydisplay").html($(this).prop('outerHTML'));
        $("#graydisplay").fadeIn(200);
    });
    $("#graydisplay, #graydisplay img").click(function() {
        $("#graydisplay").fadeOut(200);
    });


// モーダル２
    $('.open-modal').click(function() {
        $('#bg').css('display','block');
        $('#modal').css('display','block');
    });
    $('.close-modal, #bg').click(function() {
        $('#bg').css('display','none');
        $('#modal').css('display','none');
    });

// そのままでは２回目のモーダル表示ができないのでclassのつけはずしで対応予定
//     $('.').click(function(){
//         $('p').click(function(){
//             $('body').append('<div id="bg">').append('<div id="modal">');
//             $('#modal').append($(data));

//             $('#bg').click(function(){
//                 $('#bg,#modal').remove();
//             });
//         });    
//     });

    // $('.slider').slick({
    //     arrows:false,
    //     asNavFor:'.thumb',
    // });
    // $('.thumb').slick({
    //     asNavFor:'.slider',
    //     focusOnSelect: true,
    //     slidesToShow:4,
    //     slidesToScroll:1
    // });
    const slider = $('.slider').slick({
        arrows: false,
        asNavFor: '.thumb'
    });
    const thumb = $('.thumb').slick({
        asNavFor: '.slider',
        focusOnSelect: true,
        slidesToShow: 4,
        slidesToScroll: 1
    });
    $('.open-modal').click(function() {
        slider.css('opacity', 0);
        $('#modal').css('opacity','0');
        // slider.animate({ 'z-index': 1 }, 10, function() {
            slider.slick('setPosition');
            slider.animate({ opacity: 1 });
            $('#modal').animate({opacity: 1});

        // });
        thumb.css('opacity', 0);
        // thumb.animate({ 'z-index': 1 }, 10, function() {
            thumb.slick('setPosition');
            thumb.animate({ opacity: 1 });
        // });
    });
    
    


    // コンタクトフォーム
    $('.mb-2').click(function() {
        const name = $('#formGroupExampleInput').val();
        const mail = $('#formGroupExampleInput2').val();
        const content = $('#formGroupExampleInput3').val();


        if (name == ""){
            window.alert("氏名を入力してください");
        }else if (mail == ""){
            window.alert("メールアドレスを入力してください");
        }else if (content == ""){
            window.alert("内容を入力してください");
        }else{
            console.log("名前：" + name);
            console.log("メールアドレス：" + mail);
            console.log("内容：" + content);
            window.alert("お問い合わせありがとうございました。");

            Form.reset("userData");
            // $('#formGroupExampleInput').reset();
            // $('#formGroupExampleInput2').reset();
            // $('#formGroupExampleInput3').reset();
            return false;
        }
    });






})