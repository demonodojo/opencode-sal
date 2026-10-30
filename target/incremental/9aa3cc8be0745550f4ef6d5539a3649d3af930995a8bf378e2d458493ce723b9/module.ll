target triple = "x86_64-unknown-none-elf"

%SalBytes = type { ptr, i64 }
@sal_bytes_oob = private unnamed_addr constant [20 x i8] c"bytes: out of bounds"

declare i64 @sal_print_i64(i64)
declare void @sal_panic(ptr)
declare void @sal_bytes_check(i64, i64, i64)
declare i64 @sal_os_syscall(i64, i64, i64, i64, i64, i64, i64)
declare void @sal_matmul_f32(ptr, ptr, ptr, i64, i64, i64)
declare void @sal_matmul_f16(ptr, ptr, ptr, i64, i64, i64)
declare void @sal_matmul_bf16(ptr, ptr, ptr, i64, i64, i64)
declare void @sal_qmatmul_f32(ptr, ptr, ptr, ptr, i64, i64, i64, i64)
declare void @sal_attention_f32(ptr, ptr, ptr, ptr, i64, i64, i64, i64, i64)
declare void @sal_tensor_write_row_f32(ptr, i64, ptr, i64)
declare void @sal_tensor_write_rows_f32(ptr, i64, ptr, i64, i64)
declare void @sal_softmax_f32(ptr, i64)
declare void @sal_softmax_axis_f32(ptr, i64, i64)
declare void @sal_silu_f32(ptr, ptr, i64)
declare void @sal_rope_f32(ptr, i64, i64, i64)
declare void @sal_rms_norm_f32(ptr, ptr, ptr, i64, double)
declare i64 @sal_argmax_axis_f32(ptr, i64)
declare void @sal_region_begin(i64, i64)
declare void @sal_region_end(i64)
declare void @sal_tensor_bin_f32(i32, ptr, ptr, ptr, i64, i32, double)
declare void @sal_tensor_cmp_f32(i32, ptr, ptr, ptr, i64, i32, double)
declare void @sal_tensor_neg_f32(ptr, ptr, i64)
declare void @sal_tensor_not_i8(ptr, ptr, i64)
declare i64 @sal_mask_select_count(ptr, i64)
declare void @sal_tensor_select_f32(ptr, ptr, ptr, i64)
declare void @sal_tensor_select_i8(ptr, ptr, ptr, i64)
declare ptr @sal_list_select(ptr, ptr, i64)
declare ptr @sal_load_f32(ptr, ptr)
declare ptr @sal_place_malloc(i64, i32)
declare void @sal_place_free(ptr)
declare ptr @sal_place_copy(ptr, i64, i32)
declare void @sal_on_enter(i32)
declare i64 @sal_place_launches(i64)
declare ptr @malloc(i64)
declare void @free(ptr)
declare void @sal_runtime_init(i64, ptr)
declare i64 @sal_argc()
declare ptr @sal_argv(i64)
declare ptr @sal_read_file(ptr)
declare i64 @sal_path_readable(ptr)
declare i64 @sal_write_file(ptr, ptr)
declare i64 @sal_write_png(ptr, i64, i64, ptr)
declare ptr @sal_image_new(i64, i64)
declare i64 @sal_print_str(ptr)
declare i64 @sal_eprint_str(ptr)
declare ptr @sal_getenv(ptr)
declare i64 @sal_mkdir_p(ptr)
declare i64 @sal_str_eq(ptr, ptr)
declare i64 @sal_str_contains(ptr, ptr)
declare i64 @sal_str_len(ptr)
declare i64 @sal_str_bytes(ptr)
declare ptr @sal_str_concat(ptr, ptr)
declare ptr @sal_str_append(ptr, ptr)
declare ptr @sal_strdup(ptr)
declare ptr @sal_select_str(i64, ptr, ptr)
declare void @sal_free(ptr)
declare i64 @sal_copy_file(ptr, ptr)
declare i64 @sal_copy_self(ptr)
declare i64 @sal_not(i64)
declare i64 @sal_gated_print_str(i64, ptr)
declare i64 @sal_gated_copy_self(i64, ptr)
declare i64 @sal_str_char(ptr, i64)
declare i64 @sal_str_skip(ptr, i64, i64, i64)
declare i64 @sal_str_hash(ptr, i64)
declare ptr @sal_map_new()
declare i64 @sal_map_get(ptr, ptr)
declare i64 @sal_map_put(ptr, ptr, i64)
declare ptr @sal_ir_text(ptr)
declare ptr @sal_lex_src(ptr)
declare ptr @sal_str_slice(ptr, i64, i64)
declare ptr @sal_int_to_str(i64)
declare ptr @sal_char_to_str(i64)
declare ptr @sal_str_from_int(i64)
declare i64 @sal_str_as_int(ptr)
declare i64 @sal_str_to_f64_bits(ptr)
declare ptr @sal_f64_bits_to_str(i64)
declare i64 @sal_now_ns()
declare ptr @sal_vec_new()
declare i64 @sal_vec_push(ptr, i64)
declare i64 @sal_vec_get(ptr, i64)
declare i64 @sal_vec_set(ptr, i64, i64)
declare i64 @sal_vec_len(ptr)
declare void @sal_vec_free(ptr)
declare ptr @sal_bytes_new(i64)
declare i64 @sal_bytes_len(ptr)
declare i64 @sal_bytes_fill(ptr, i64, i64, i64)
declare i64 @sal_bytes_fill_u32(ptr, i64, i64, i64)
declare i64 @sal_bytes_copy(ptr, i64, ptr, i64, i64)
declare i64 @sal_str_bytes_copy(ptr, i64, ptr)
declare ptr @sal_bytes_to_str(ptr)
declare ptr @sal_bytes_view(ptr, i64, i64)
declare ptr @sal_bytes_view_mem(i64, i64)
declare i64 @sal_bytes_ptr(ptr)
declare ptr @sal_list_new()
declare ptr @sal_list_new_typed(i64)
declare ptr @sal_list_push(ptr, i64)
declare i64 @sal_list_len(ptr)
declare i64 @sal_list_get(ptr, i64)
declare i64 @sal_clang(ptr, ptr)
declare ptr @sal_realpath(ptr)
declare i64 @sal_clang_obj(ptr, ptr)
declare i64 @sal_link_objs(ptr, ptr)
declare ptr @sal_tmp_path(ptr)
declare ptr @sal_exec_capture(ptr, ptr)
declare i64 @sal_exec_compile(ptr, ptr, ptr)
declare i64 @sal_gated_exec_compile(i64, ptr, ptr, ptr)
declare void @sal_instrument_init()
declare void @sal_instrument_shutdown()
declare ptr @sal_instrument_malloc(i64, i32, ptr)
declare void @sal_instrument_alloc(ptr, i64, i32, ptr)
declare void @sal_instrument_free(ptr)
declare void @sal_instrument_check_f32(ptr, i64, ptr)
declare void @sal_instrument_check_ptr(ptr, i64, i32, ptr)
declare void @sal_instrument_check_index(i64, i64, ptr)
declare ptr @sal_dict_new(i64, i64)
declare ptr @sal_dict_put(ptr, ptr, i64)
declare i64 @sal_dict_get(ptr, ptr)

declare i64 @nr_dns_resolve()
declare i64 @nr_stat()
declare i64 @o_CREAT()
declare i64 @dirent_off_ino()
declare i64 @nr_read_timeout()
declare i64 @nr_mkdir()
declare i64 @spawnio_off_path_ptr()
declare i64 @nr_sleep_ms()
declare i64 @nr_read()
declare i64 @ft_dir()
declare i64 @spawnio_size()
declare i64 @dirent_off_file_type()
declare i64 @u32_b2(i64 %arg0)
declare i64 @nr_spawn_io()
declare i64 @nr_uptime_ms()
declare i64 @ft_file()
declare i64 @nr_kill()
declare i64 @spawnio_off_argv_ptr()
declare i64 @spawnio_off_log_fd()
declare i64 @nr_open()
declare i64 @nr_getdents()
declare i64 @spawnio_off_path_len()
declare i64 @nr_close()
declare i64 @spawnio_off_stderr()
declare i64 @u32_b0(i64 %arg0)
declare i64 @dirent_size()
declare i64 @spawnio_off_stdin()
declare i64 @nr_rename()
declare i64 @nr_getenv()
declare i64 @nr_tcp_connect()
declare i64 @nr_write()
declare i64 @u8(i64 %arg0)
declare i64 @spawnio_off_argv_count()
declare i64 @nr_tcp_listen()
declare i64 @mod_pos(i64 %arg0, i64 %arg1)
declare i64 @dirent_off_name_len()
declare i64 @dirent_off_name()
declare i64 @sockaddr_size()
declare i64 @o_RDONLY()
declare i64 @nr_tcp_accept()
declare i64 @spawnio_off_stdout()
declare i64 @nr_wait()
declare i64 @nr_unlink()
declare i64 @o_WRONLY()

@.site.alloc = private unnamed_addr constant [6 x i8] c"alloc\00"
@.site.matmul = private unnamed_addr constant [7 x i8] c"matmul\00"
@.site.load = private unnamed_addr constant [5 x i8] c"load\00"
@.site.softmax = private unnamed_addr constant [8 x i8] c"softmax\00"
@.site.access = private unnamed_addr constant [7 x i8] c"access\00"
@.site.index = private unnamed_addr constant [6 x i8] c"index\00"

define i64 @tcp_listen(i64 %port) {
entry:
  %t1 = call i64 @nr_tcp_listen()
  %t2 = add i64 0, 0
  %t3 = add i64 0, 0
  %t4 = add i64 0, 0
  %t5 = add i64 0, 0
  %t6 = add i64 0, 0
  %t7 = call i64 @sal_os_syscall(i64 %t1, i64 %port, i64 0, i64 0, i64 0, i64 0, i64 0)
  ret i64 %t7
}
define i64 @tcp_accept(i64 %fd, i64 %ms) {
entry:
  %t1 = call i64 @nr_tcp_accept()
  %t2 = add i64 0, 0
  %t3 = add i64 0, 0
  %t4 = add i64 0, 0
  %t5 = add i64 0, 0
  %t6 = call i64 @sal_os_syscall(i64 %t1, i64 %fd, i64 %ms, i64 0, i64 0, i64 0, i64 0)
  ret i64 %t6
}
define i64 @sockaddr_loopback(i64 %port) {
entry:
  %t1 = call i64 @sockaddr_size()
  %t2_p = call ptr @sal_bytes_new(i64 %t1)
  %t2 = ptrtoint ptr %t2_p to i64
  %cast1 = inttoptr i64 %t2 to ptr
  %t3 = call i64 @sal_bytes_ptr(ptr %cast1)
  %t4 = call i64 @sockaddr_size()
  %t5_p = call ptr @sal_bytes_view_mem(i64 %t3, i64 %t4)
  %t5 = ptrtoint ptr %t5_p to i64
  %t6 = add i64 0, 0
  %t7 = add i64 0, 127
  %sbp2 = inttoptr i64 %t5 to ptr
  %sd3 = load ptr, ptr %sbp2
  %slp4 = getelementptr i8, ptr %sbp2, i64 8
  %sn5 = load i64, ptr %slp4
  call void @sal_bytes_check(i64 0, i64 1, i64 %sn5)
  %sgp6 = getelementptr i8, ptr %sd3, i64 0
  %sn7 = trunc i64 127 to i8
  store i8 %sn7, ptr %sgp6
  %t8 = add i64 0, 0
  %t9 = add i64 0, 1
  %t10 = add i64 0, 0
  %sbp8 = inttoptr i64 %t5 to ptr
  %sd9 = load ptr, ptr %sbp8
  %slp10 = getelementptr i8, ptr %sbp8, i64 8
  %sn11 = load i64, ptr %slp10
  call void @sal_bytes_check(i64 1, i64 1, i64 %sn11)
  %sgp12 = getelementptr i8, ptr %sd9, i64 1
  %sn13 = trunc i64 0 to i8
  store i8 %sn13, ptr %sgp12
  %t11 = add i64 0, 0
  %t12 = add i64 0, 2
  %t13 = add i64 0, 0
  %sbp14 = inttoptr i64 %t5 to ptr
  %sd15 = load ptr, ptr %sbp14
  %slp16 = getelementptr i8, ptr %sbp14, i64 8
  %sn17 = load i64, ptr %slp16
  call void @sal_bytes_check(i64 2, i64 1, i64 %sn17)
  %sgp18 = getelementptr i8, ptr %sd15, i64 2
  %sn19 = trunc i64 0 to i8
  store i8 %sn19, ptr %sgp18
  %t14 = add i64 0, 0
  %t15 = add i64 0, 3
  %t16 = add i64 0, 1
  %sbp20 = inttoptr i64 %t5 to ptr
  %sd21 = load ptr, ptr %sbp20
  %slp22 = getelementptr i8, ptr %sbp20, i64 8
  %sn23 = load i64, ptr %slp22
  call void @sal_bytes_check(i64 3, i64 1, i64 %sn23)
  %sgp24 = getelementptr i8, ptr %sd21, i64 3
  %sn25 = trunc i64 1 to i8
  store i8 %sn25, ptr %sgp24
  %t17 = add i64 0, 0
  %t18 = add i64 0, 4
  %t19 = call i64 @u32_b2(i64 %port)
  %sbp26 = inttoptr i64 %t5 to ptr
  %sd27 = load ptr, ptr %sbp26
  %slp28 = getelementptr i8, ptr %sbp26, i64 8
  %sn29 = load i64, ptr %slp28
  call void @sal_bytes_check(i64 4, i64 1, i64 %sn29)
  %sgp30 = getelementptr i8, ptr %sd27, i64 4
  %sn31 = trunc i64 %t19 to i8
  store i8 %sn31, ptr %sgp30
  %t20 = add i64 0, 0
  %t21 = add i64 0, 5
  %t22 = call i64 @u32_b0(i64 %port)
  %sbp32 = inttoptr i64 %t5 to ptr
  %sd33 = load ptr, ptr %sbp32
  %slp34 = getelementptr i8, ptr %sbp32, i64 8
  %sn35 = load i64, ptr %slp34
  call void @sal_bytes_check(i64 5, i64 1, i64 %sn35)
  %sgp36 = getelementptr i8, ptr %sd33, i64 5
  %sn37 = trunc i64 %t22 to i8
  store i8 %sn37, ptr %sgp36
  %t23 = add i64 0, 0
  %t24 = add i64 0, 6
  %t25 = add i64 0, 0
  %sbp38 = inttoptr i64 %t5 to ptr
  %sd39 = load ptr, ptr %sbp38
  %slp40 = getelementptr i8, ptr %sbp38, i64 8
  %sn41 = load i64, ptr %slp40
  call void @sal_bytes_check(i64 6, i64 1, i64 %sn41)
  %sgp42 = getelementptr i8, ptr %sd39, i64 6
  %sn43 = trunc i64 0 to i8
  store i8 %sn43, ptr %sgp42
  %t26 = add i64 0, 0
  %t27 = add i64 0, 7
  %t28 = add i64 0, 0
  %sbp44 = inttoptr i64 %t5 to ptr
  %sd45 = load ptr, ptr %sbp44
  %slp46 = getelementptr i8, ptr %sbp44, i64 8
  %sn47 = load i64, ptr %slp46
  call void @sal_bytes_check(i64 7, i64 1, i64 %sn47)
  %sgp48 = getelementptr i8, ptr %sd45, i64 7
  %sn49 = trunc i64 0 to i8
  store i8 %sn49, ptr %sgp48
  %t29 = add i64 0, 0
  ret i64 %t3
}
define i64 @tcp_connect_loopback(i64 %port, i64 %timeout_ms) {
entry:
  %t1 = call i64 @sockaddr_loopback(i64 %port)
  %t2 = call i64 @nr_tcp_connect()
  %t3 = add i64 0, 0
  %t4 = add i64 0, 0
  %t5 = add i64 0, 0
  %t6 = add i64 0, 0
  %t7 = call i64 @sal_os_syscall(i64 %t2, i64 %t1, i64 %timeout_ms, i64 0, i64 0, i64 0, i64 0)
  ret i64 %t7
}
define i64 @dns_resolve_ptr(i64 %host_ptr, i64 %host_len, i64 %out_ptr) {
entry:
  %t1 = call i64 @nr_dns_resolve()
  %t2 = add i64 0, 0
  %t3 = add i64 0, 0
  %t4 = add i64 0, 0
  %t5 = call i64 @sal_os_syscall(i64 %t1, i64 %host_ptr, i64 %host_len, i64 %out_ptr, i64 0, i64 0, i64 0)
  ret i64 %t5
}
