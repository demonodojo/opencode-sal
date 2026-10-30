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

declare i64 @spawnio_off_argv_count()
declare i64 @nr_tcp_listen()
declare i64 @dirent_size()
declare i64 @ft_dir()
declare i64 @nr_getenv()
declare i64 @o_WRONLY()
declare i64 @nr_getdents()
declare i64 @nr_read_timeout()
declare i64 @nr_open()
declare i64 @getdents_fd(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @ft_file()
declare i64 @dirent_off_ino()
declare i64 @nr_kill()
declare i64 @read_timeout_fd(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3)
declare i64 @o_RDONLY()
declare i64 @dirent_off_name_len()
declare i64 @read_fd(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @nr_read()
declare i64 @stat_path_ptr(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3)
declare i64 @spawnio_off_path_ptr()
declare i64 @nr_uptime_ms()
declare i64 @o_CREAT()
declare i64 @nr_sleep_ms()
declare i64 @dirent_off_file_type()
declare i64 @spawnio_off_log_fd()
declare i64 @open_read_path_ptr(i64 %arg0, i64 %arg1)
declare i64 @sockaddr_size()
declare i64 @path_to_buf(i64 %arg0)
declare i64 @mkdir_path_ptr(i64 %arg0, i64 %arg1)
declare i64 @spawnio_off_stderr()
declare i64 @nr_tcp_accept()
declare i64 @spawnio_off_stdin()
declare i64 @nr_stat()
declare i64 @write_file_path(i64 %arg0, i64 %arg1)
declare i64 @open_read(i64 %arg0)
declare i64 @nr_mkdir()
declare i64 @close_fd(i64 %arg0)
declare i64 @dirent_off_name()
declare i64 @nr_dns_resolve()
declare i64 @spawnio_off_argv_ptr()
declare i64 @nr_unlink()
declare i64 @spawnio_size()
declare i64 @write_str_fd(i64 %arg0, i64 %arg1)
declare i64 @nr_wait()
declare i64 @rename_path_ptr(i64 %arg0, i64 %arg1, i64 %arg2, i64 %arg3)
declare i64 @spawnio_off_path_len()
declare i64 @nr_rename()
declare i64 @open_flags(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @write_fd(i64 %arg0, i64 %arg1, i64 %arg2)
declare i64 @nr_write()
declare i64 @nr_close()
declare i64 @unlink_path_ptr(i64 %arg0, i64 %arg1)
declare i64 @spawnio_off_stdout()
declare i64 @nr_tcp_connect()
declare i64 @nr_spawn_io()

@.site.alloc = private unnamed_addr constant [6 x i8] c"alloc\00"
@.site.matmul = private unnamed_addr constant [7 x i8] c"matmul\00"
@.site.load = private unnamed_addr constant [5 x i8] c"load\00"
@.site.softmax = private unnamed_addr constant [8 x i8] c"softmax\00"
@.site.access = private unnamed_addr constant [7 x i8] c"access\00"
@.site.index = private unnamed_addr constant [6 x i8] c"index\00"

define i64 @spawn_string_buf(i64 %s) {
entry:
  %cast1 = inttoptr i64 %s to ptr
  %t1 = call i64 @sal_str_len(ptr %cast1)
  %t2 = add i64 0, 1
  %t3 = add i64 %t1, 1
  %t4_p = call ptr @sal_bytes_new(i64 %t3)
  %t4 = ptrtoint ptr %t4_p to i64
  %t5 = add i64 0, 0
  %cast2 = inttoptr i64 %t4 to ptr
  %cast3 = inttoptr i64 %s to ptr
  %t6 = call i64 @sal_str_bytes_copy(ptr %cast2, i64 0, ptr %cast3)
  ret i64 %t4
}
define i64 @spawn_argv_slot_ptr(i64 %tab, i64 %i, i64 %buf, i64 %len) {
entry:
  %t1 = add i64 0, 16
  %t2 = mul i64 %i, 16
  %cast1 = inttoptr i64 %buf to ptr
  %t3 = call i64 @sal_bytes_ptr(ptr %cast1)
  %sbp2 = inttoptr i64 %tab to ptr
  %sd3 = load ptr, ptr %sbp2
  %slp4 = getelementptr i8, ptr %sbp2, i64 8
  %sn5 = load i64, ptr %slp4
  call void @sal_bytes_check(i64 %t2, i64 8, i64 %sn5)
  %sgp6 = getelementptr i8, ptr %sd3, i64 %t2
  store i64 %t3, ptr %sgp6
  %t4 = add i64 0, 0
  %t5 = add i64 0, 16
  %t6 = mul i64 %i, 16
  %t7 = add i64 0, 8
  %t8 = add i64 %t6, 8
  %sbp7 = inttoptr i64 %tab to ptr
  %sd8 = load ptr, ptr %sbp7
  %slp9 = getelementptr i8, ptr %sbp7, i64 8
  %sn10 = load i64, ptr %slp9
  call void @sal_bytes_check(i64 %t8, i64 8, i64 %sn10)
  %sgp11 = getelementptr i8, ptr %sd8, i64 %t8
  store i64 %len, ptr %sgp11
  %t9 = add i64 0, 0
  %t10 = add i64 0, 0
  ret i64 0
}
define i64 @spawn_io_full(i64 %path, i64 %stdin, i64 %stdout, i64 %stderr, i64 %log_fd) {
entry:
  %t1 = call i64 @spawn_string_buf(i64 %path)
  %cast1 = inttoptr i64 %path to ptr
  %t2 = call i64 @sal_str_len(ptr %cast1)
  %t3 = add i64 0, 16
  %t4_p = call ptr @sal_bytes_new(i64 16)
  %t4 = ptrtoint ptr %t4_p to i64
  %t5 = add i64 0, 0
  %t6 = call i64 @spawn_argv_slot_ptr(i64 %t4, i64 0, i64 %t1, i64 %t2)
  %t7 = call i64 @spawnio_size()
  %t8_p = call ptr @sal_bytes_new(i64 %t7)
  %t8 = ptrtoint ptr %t8_p to i64
  %t9 = call i64 @spawnio_off_path_ptr()
  %cast2 = inttoptr i64 %t1 to ptr
  %t10 = call i64 @sal_bytes_ptr(ptr %cast2)
  %sbp3 = inttoptr i64 %t8 to ptr
  %sd4 = load ptr, ptr %sbp3
  %slp5 = getelementptr i8, ptr %sbp3, i64 8
  %sn6 = load i64, ptr %slp5
  call void @sal_bytes_check(i64 %t9, i64 8, i64 %sn6)
  %sgp7 = getelementptr i8, ptr %sd4, i64 %t9
  store i64 %t10, ptr %sgp7
  %t11 = add i64 0, 0
  %t12 = call i64 @spawnio_off_path_len()
  %sbp8 = inttoptr i64 %t8 to ptr
  %sd9 = load ptr, ptr %sbp8
  %slp10 = getelementptr i8, ptr %sbp8, i64 8
  %sn11 = load i64, ptr %slp10
  call void @sal_bytes_check(i64 %t12, i64 8, i64 %sn11)
  %sgp12 = getelementptr i8, ptr %sd9, i64 %t12
  store i64 %t2, ptr %sgp12
  %t13 = add i64 0, 0
  %t14 = call i64 @spawnio_off_stdin()
  %sbp13 = inttoptr i64 %t8 to ptr
  %sd14 = load ptr, ptr %sbp13
  %slp15 = getelementptr i8, ptr %sbp13, i64 8
  %sn16 = load i64, ptr %slp15
  call void @sal_bytes_check(i64 %t14, i64 8, i64 %sn16)
  %sgp17 = getelementptr i8, ptr %sd14, i64 %t14
  store i64 %stdin, ptr %sgp17
  %t15 = add i64 0, 0
  %t16 = call i64 @spawnio_off_stdout()
  %sbp18 = inttoptr i64 %t8 to ptr
  %sd19 = load ptr, ptr %sbp18
  %slp20 = getelementptr i8, ptr %sbp18, i64 8
  %sn21 = load i64, ptr %slp20
  call void @sal_bytes_check(i64 %t16, i64 8, i64 %sn21)
  %sgp22 = getelementptr i8, ptr %sd19, i64 %t16
  store i64 %stdout, ptr %sgp22
  %t17 = add i64 0, 0
  %t18 = call i64 @spawnio_off_stderr()
  %sbp23 = inttoptr i64 %t8 to ptr
  %sd24 = load ptr, ptr %sbp23
  %slp25 = getelementptr i8, ptr %sbp23, i64 8
  %sn26 = load i64, ptr %slp25
  call void @sal_bytes_check(i64 %t18, i64 8, i64 %sn26)
  %sgp27 = getelementptr i8, ptr %sd24, i64 %t18
  store i64 %stderr, ptr %sgp27
  %t19 = add i64 0, 0
  %t20 = call i64 @spawnio_off_argv_ptr()
  %cast28 = inttoptr i64 %t4 to ptr
  %t21 = call i64 @sal_bytes_ptr(ptr %cast28)
  %sbp29 = inttoptr i64 %t8 to ptr
  %sd30 = load ptr, ptr %sbp29
  %slp31 = getelementptr i8, ptr %sbp29, i64 8
  %sn32 = load i64, ptr %slp31
  call void @sal_bytes_check(i64 %t20, i64 8, i64 %sn32)
  %sgp33 = getelementptr i8, ptr %sd30, i64 %t20
  store i64 %t21, ptr %sgp33
  %t22 = add i64 0, 0
  %t23 = call i64 @spawnio_off_argv_count()
  %t24 = add i64 0, 1
  %sbp34 = inttoptr i64 %t8 to ptr
  %sd35 = load ptr, ptr %sbp34
  %slp36 = getelementptr i8, ptr %sbp34, i64 8
  %sn37 = load i64, ptr %slp36
  call void @sal_bytes_check(i64 %t23, i64 8, i64 %sn37)
  %sgp38 = getelementptr i8, ptr %sd35, i64 %t23
  store i64 1, ptr %sgp38
  %t25 = add i64 0, 0
  %t26 = call i64 @spawnio_off_log_fd()
  %sbp39 = inttoptr i64 %t8 to ptr
  %sd40 = load ptr, ptr %sbp39
  %slp41 = getelementptr i8, ptr %sbp39, i64 8
  %sn42 = load i64, ptr %slp41
  call void @sal_bytes_check(i64 %t26, i64 8, i64 %sn42)
  %sgp43 = getelementptr i8, ptr %sd40, i64 %t26
  store i64 %log_fd, ptr %sgp43
  %t27 = add i64 0, 0
  %t28 = call i64 @nr_spawn_io()
  %cast44 = inttoptr i64 %t8 to ptr
  %t29 = call i64 @sal_bytes_ptr(ptr %cast44)
  %t30 = add i64 0, 0
  %t31 = add i64 0, 0
  %t32 = add i64 0, 0
  %t33 = add i64 0, 0
  %t34 = add i64 0, 0
  %t35 = call i64 @sal_os_syscall(i64 %t28, i64 %t29, i64 0, i64 0, i64 0, i64 0, i64 0)
  ret i64 %t35
}
define i64 @wait_pid(i64 %pid) {
entry:
  %t1 = call i64 @nr_wait()
  %t2 = add i64 0, 0
  %t3 = add i64 0, 0
  %t4 = add i64 0, 0
  %t5 = add i64 0, 0
  %t6 = add i64 0, 0
  %t7 = call i64 @sal_os_syscall(i64 %t1, i64 %pid, i64 0, i64 0, i64 0, i64 0, i64 0)
  ret i64 %t7
}
define i64 @kill_pid(i64 %pid, i64 %sig) {
entry:
  %t1 = call i64 @nr_kill()
  %t2 = add i64 0, 0
  %t3 = add i64 0, 0
  %t4 = add i64 0, 0
  %t5 = add i64 0, 0
  %t6 = call i64 @sal_os_syscall(i64 %t1, i64 %pid, i64 %sig, i64 0, i64 0, i64 0, i64 0)
  ret i64 %t6
}
